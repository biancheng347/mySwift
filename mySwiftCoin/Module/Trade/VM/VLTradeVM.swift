import Foundation
import RxSwift
import RxCocoa
import RxRelay

/// 交易页 VM：分类/币对切换、OKX WS 行情、K 线/表单。
final class VLTradeVM: RxswiftError, RxswiftLoading,
                       DisposeProtocol, WeakHandleProtocol {

    /// 当前交易对展示名。
    private(set) var symbol: String = VLTradePair.btcUSDT
    /// 交易对 Relay（供 UI 同步）。
    private(set) lazy var symbolPublisher = BehaviorRelay<String>(value: VLTradePair.btcUSDT)
    /// 顶部分类。
    private(set) lazy var categoryPublisher = BehaviorRelay<VLTradeCategory>(value: .spot)
    /// ticker 状态。
    private(set) lazy var tickerPublisher = BehaviorRelay<VLTradeTickerModel?>(value: nil)
    /// K 线蜡烛。
    private(set) lazy var candlesPublisher = BehaviorRelay<[VLTradeCandleModel]>(value: [])
    /// 当前周期。
    private(set) lazy var timeframePublisher = BehaviorRelay<VLTradeTimeframe>(value: .default)
    /// 盘口。
    private(set) lazy var orderBookPublisher = BehaviorRelay<VLTradeOrderBookModel?>(value: nil)
    /// 下单表单。
    private(set) lazy var formPublisher = BehaviorRelay<VLTradeOrderFormModel>(value: VLTradeOrderFormModel())
    /// 底部持仓/委托/资产。
    private(set) lazy var accountPublisher = BehaviorRelay<VLTradeAccountSnapshotModel>(
        value: VLTradeAccountSnapshotModel()
    )
    /// 底部选中 Tab。
    private(set) lazy var bottomTabPublisher = BehaviorRelay<VLTradeBottomTab>(value: .openOrders)

    private let service: VLTradeService
    private let socket: VLTradeOKXWebSocket
    private let loadTrigger = PublishRelay<Void>()
    private let candlesTrigger = PublishRelay<VLTradeTimeframe>()
    private let useLiveSocket: Bool
    private var restPollSubscription: Disposable?

    /// 注入服务 / socket；单测关闭 live。
    init(
        service: VLTradeService = VLTradeService(),
        socket: VLTradeOKXWebSocket = VLTradeOKXWebSocket(),
        useLiveSocket: Bool = true
    ) {
        self.service = service
        self.socket = socket
        self.useLiveSocket = useLiveSocket
        if !useLiveSocket {
            self.service.useLiveREST = false
        }
        bindLoad()
        bindCandles()
        bindSocket()
        bindRestPollingFallback()
    }

    deinit {
        restPollSubscription?.dispose()
        socket.disconnect()
    }

    /// 首次加载 REST 兜底 + 订阅 WS。
    func load() {
        loadTrigger.accept(())
        candlesTrigger.accept(timeframePublisher.value)
        resubscribeSocket()
    }

    /// 点击切换分类（无滑动）。
    func selectCategory(_ category: VLTradeCategory) {
        guard category != categoryPublisher.value else { return }
        categoryPublisher.accept(category)
        if category.isMarketPanel {
            bottomTabPublisher.accept(category == .futures ? .positions : .openOrders)
            resetMarketState()
            resubscribeSocket()
            loadTrigger.accept(())
            candlesTrigger.accept(timeframePublisher.value)
        } else {
            socket.disconnect()
            restPollSubscription?.dispose()
            restPollSubscription = nil
        }
    }

    /// 切换 BTC / ETH 交易对。
    func selectSymbol(_ symbol: String) {
        guard VLTradePair.tradableSymbols.contains(symbol), symbol != self.symbol else { return }
        self.symbol = symbol
        symbolPublisher.accept(symbol)
        resetMarketState()
        resubscribeSocket()
        loadTrigger.accept(())
        candlesTrigger.accept(timeframePublisher.value)
    }

    /// 切换 K 线周期并重载蜡烛。
    func selectTimeframe(_ timeframe: VLTradeTimeframe) {
        guard timeframe != .more else { return }
        timeframePublisher.accept(timeframe)
        candlesTrigger.accept(timeframe)
    }

    /// 切换买入/卖出侧。
    func selectSide(_ side: VLTradeSide) {
        let form = formPublisher.value
        form.side = side
        formPublisher.accept(form)
    }

    /// 合约全仓 / 逐仓（对齐 OKX App 切换）。
    func selectMarginMode(isCross: Bool) {
        let form = formPublisher.value
        guard form.isCrossMargin != isCross else { return }
        form.isCrossMargin = isCross
        formPublisher.accept(form)
    }

    /// 切换底部 Tab。
    func selectBottomTab(_ tab: VLTradeBottomTab) {
        let category = categoryPublisher.value
        let allowed = category == .futures
            ? VLTradeBottomTab.futuresTabs
            : VLTradeBottomTab.spotTabs
        guard allowed.contains(tab), tab != bottomTabPublisher.value else { return }
        bottomTabPublisher.accept(tab)
    }

    /// 提交下单占位。
    func submitOrder() {
        #if DEBUG
        let form = formPublisher.value
        print("[VLTradeVM] submit side=\(form.side) price=\(form.price) amount=\(form.amount) cross=\(form.isCrossMargin)")
        #endif
    }
}

fileprivate extension VLTradeVM {

    /// 换币/换分类时清空行情，避免旧数据闪现。
    func resetMarketState() {
        tickerPublisher.accept(nil)
        orderBookPublisher.accept(nil)
        candlesPublisher.accept([])
        accountPublisher.accept(VLTradeAccountSnapshotModel())
        let form = formPublisher.value
        form.price = ""
        formPublisher.accept(form)
    }

    /// 按当前分类订阅 OKX：BTC+ETH ticker，当前 books5。
    func resubscribeSocket() {
        guard useLiveSocket else { return }
        let category = categoryPublisher.value
        guard category.isMarketPanel else {
            socket.disconnect()
            return
        }
        let bookInstId = VLTradeOKXMapper.instId(for: category, symbol: symbol)
        let tickerInstIds = VLTradePair.tradableSymbols.map {
            VLTradeOKXMapper.instId(for: category, symbol: $0)
        }
        socket.subscribe(bookInstId: bookInstId, tickerInstIds: tickerInstIds)
    }

    /// 绑定 WS → Relays（仅接受当前 instId）。
    func bindSocket() {
        socket.tickerPublisher.asObservable()
            .observeOnThread(isMain: true)
            .subscribe(onNext: weakHandle { this, ticker in
                guard let this else { return }
                let expected = VLTradeOKXMapper.instId(
                    for: this.categoryPublisher.value,
                    symbol: this.symbol
                )
                guard ticker.instId == expected else { return }
                this.applyLiveTicker(ticker)
            })
            .disposed(by: disposeBag)

        socket.orderBookPublisher.asObservable()
            .observeOnThread(isMain: true)
            .subscribe(onNext: weakHandle { this, book in
                this?.orderBookPublisher.accept(book)
            })
            .disposed(by: disposeBag)
    }

    /// WS TLS/断线时用 REST 轮询 ticker+盘口，WS 恢复后自动停。
    func bindRestPollingFallback() {
        guard useLiveSocket else { return }
        socket.connectedPublisher.asObservable()
            .distinctUntilChanged()
            .observeOnThread(isMain: true)
            .subscribe(onNext: weakHandle { this, connected in
                guard let this else { return }
                this.restPollSubscription?.dispose()
                this.restPollSubscription = nil
                guard !connected, this.categoryPublisher.value.isMarketPanel else { return }
                this.startRestPolling()
            })
            .disposed(by: disposeBag)
    }

    /// 启动 REST 行情轮询（约 2s）。
    func startRestPolling() {
        restPollSubscription = Observable<Int>
            .interval(.milliseconds(2000), scheduler: MainScheduler.instance)
            .startWith(0)
            .flatMapLatest(weakHandle { this, _ -> Observable<(VLTradeTickerModel, VLTradeOrderBookModel)> in
                guard let this, !this.socket.connectedPublisher.value else { return .empty() }
                let category = this.categoryPublisher.value
                guard category.isMarketPanel else { return .empty() }
                return Observable.zip(
                    this.service.getTicker(symbol: this.symbol, category: category),
                    this.service.getOrderBook(symbol: this.symbol, category: category)
                )
                .catch { _ in .empty() }
            })
            .observeOnThread(isMain: true)
            .subscribe(onNext: weakHandle { this, pair in
                guard let this, !this.socket.connectedPublisher.value else { return }
                this.applyLiveTicker(pair.0)
                this.orderBookPublisher.accept(pair.1)
            })
    }

    /// 写入实时 ticker 并在空价格时预填表单。
    func applyLiveTicker(_ ticker: VLTradeTickerModel) {
        tickerPublisher.accept(ticker)
        let form = formPublisher.value
        if form.price.isEmpty {
            form.price = ticker.lastPrice
            formPublisher.accept(form)
        }
    }

    /// 绑定 ticker + 盘口 + 底部账户 mock。
    func bindLoad() {
        loadTrigger
            .flatMapLatest(weakHandle { this, _ -> Observable<(VLTradeTickerModel, VLTradeOrderBookModel, VLTradeAccountSnapshotModel)> in
                guard let this else { return .empty() }
                let category = this.categoryPublisher.value
                return Observable.zip(
                    this.service.getTicker(symbol: this.symbol, category: category),
                    this.service.getOrderBook(symbol: this.symbol, category: category),
                    this.service.getAccountSnapshot(symbol: this.symbol, category: category)
                )
                .observeOnThread(isMain: true)
                .trackError(this.error)
                .trackLoading(this.loading)
            })
            .subscribe(onNext: weakHandle { this, triple in
                guard let this else { return }
                if this.tickerPublisher.value == nil {
                    this.tickerPublisher.accept(triple.0)
                    let form = this.formPublisher.value
                    form.price = triple.0.lastPrice
                    this.formPublisher.accept(form)
                }
                if this.orderBookPublisher.value == nil {
                    this.orderBookPublisher.accept(triple.1)
                }
                this.accountPublisher.accept(triple.2)
            })
            .disposed(by: disposeBag)
    }

    /// 绑定周期切换触发的蜡烛加载（取消 in-flight）。
    func bindCandles() {
        candlesTrigger
            .flatMapLatest(weakHandle { this, timeframe -> Observable<[VLTradeCandleModel]> in
                guard let this else { return .empty() }
                let category = this.categoryPublisher.value
                return this.service.getCandles(
                    symbol: this.symbol,
                    timeframe: timeframe,
                    category: category
                )
                .observeOnThread(isMain: true)
                .trackError(this.error)
            })
            .subscribe(onNext: weakHandle { this, candles in
                this?.candlesPublisher.accept(candles)
            })
            .disposed(by: disposeBag)
    }
}
