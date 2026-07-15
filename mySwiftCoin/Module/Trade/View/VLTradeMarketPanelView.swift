import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// OKX 现货/合约面板：币对 + K 线 + 左表单右盘口 + 底部账户。
final class VLTradeMarketPanelView: UIView {

    private lazy var scrollView = lazyScrollView()
    private lazy var contentView = lazyContentView()
    private lazy var symbolBar = lazySymbolBar()
    private lazy var timeframeBar = lazyTimeframeBar()
    private lazy var klineView = lazyKLineView()
    private lazy var formView = lazyFormView()
    private lazy var orderBookView = lazyOrderBookView()
    private lazy var bottomPanel = lazyBottomPanel()

    private weak var tradeVM: VLTradeVM?
    private var isFutures = false

    /// 绑定 VM 并布局。
    func show(vm: VLTradeVM, isFutures: Bool) {
        self.tradeVM = vm
        self.isFutures = isFutures
        backgroundColor = VLTradeAppearance.pageBackground
        _ = scrollView
        _ = contentView
        _ = symbolBar
        _ = timeframeBar
        _ = klineView
        _ = formView
        _ = orderBookView
        _ = bottomPanel
        layoutContent()
        bind()
        refreshForm()
        refreshBottom()
    }

    /// 切换现货/合约文案。
    func applyMode(isFutures: Bool) {
        self.isFutures = isFutures
        refreshForm()
        refreshBottom()
        if let book = tradeVM?.orderBookPublisher.value {
            let ticker = tradeVM?.tickerPublisher.value
            orderBookView.apply(
                book: book,
                lastPrice: ticker?.lastPrice,
                isUp: ticker?.isUp ?? true,
                isFutures: isFutures
            )
        }
    }
}

fileprivate extension VLTradeMarketPanelView {

    /// 绑定行情 Relays。
    func bind() {
        guard let tradeVM else { return }

        tradeVM.tickerPublisher.asObservable()
            .compactMap { $0 }
            .observeOnThread(isMain: true)
            .subscribe(onNext: weakHandle { this, ticker in
                this?.symbolBar.apply(ticker: ticker, isFutures: this?.isFutures ?? false)
                if let book = this?.tradeVM?.orderBookPublisher.value {
                    this?.orderBookView.apply(
                        book: book,
                        lastPrice: ticker.lastPrice,
                        isUp: ticker.isUp,
                        isFutures: this?.isFutures ?? false
                    )
                }
                this?.refreshForm()
            })
            .disposed(by: disposeBag)

        tradeVM.orderBookPublisher.asObservable()
            .compactMap { $0 }
            .observeOnThread(isMain: true)
            .subscribe(onNext: weakHandle { this, book in
                let ticker = this?.tradeVM?.tickerPublisher.value
                this?.orderBookView.apply(
                    book: book,
                    lastPrice: ticker?.lastPrice,
                    isUp: ticker?.isUp ?? true,
                    isFutures: this?.isFutures ?? false
                )
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            tradeVM.candlesPublisher.asObservable(),
            tradeVM.timeframePublisher.asObservable()
        )
        .observeOnThread(isMain: true)
        .subscribe(onNext: weakHandle { this, pair in
            this?.klineView.reload(candles: pair.0, timeframe: pair.1)
            this?.timeframeBar.applySelected(pair.1)
        })
        .disposed(by: disposeBag)

        tradeVM.formPublisher.asObservable()
            .observeOnThread(isMain: true)
            .subscribe(onNext: weakHandle { this, _ in
                this?.refreshForm()
            })
            .disposed(by: disposeBag)

        tradeVM.symbolPublisher.asObservable()
            .observeOnThread(isMain: true)
            .subscribe(onNext: weakHandle { this, symbol in
                this?.symbolBar.applySelectedSymbol(symbol)
                this?.refreshForm()
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            tradeVM.accountPublisher.asObservable(),
            tradeVM.bottomTabPublisher.asObservable(),
            tradeVM.categoryPublisher.asObservable()
        )
        .observeOnThread(isMain: true)
        .subscribe(onNext: weakHandle { this, _ in
            this?.refreshBottom()
        })
        .disposed(by: disposeBag)

        symbolBar.onSelectSymbol = weakHandle { this, symbol in
            this?.tradeVM?.selectSymbol(symbol)
        }
        timeframeBar.onSelect = weakHandle { this, timeframe in
            this?.tradeVM?.selectTimeframe(timeframe)
        }
        formView.onSelectSide = weakHandle { this, side in
            this?.tradeVM?.selectSide(side)
        }
        formView.onSelectMarginMode = weakHandle { this, isCross in
            this?.tradeVM?.selectMarginMode(isCross: isCross)
        }
        formView.onSubmit = weakHandle { this in
            this?.tradeVM?.submitOrder()
        }
        bottomPanel.onSelectTab = weakHandle { this, tab in
            this?.tradeVM?.selectBottomTab(tab)
        }
    }

    /// 刷新表单买卖/保证金文案。
    func refreshForm() {
        guard let tradeVM else { return }
        formView.apply(
            form: tradeVM.formPublisher.value,
            isFutures: isFutures,
            baseAsset: baseAsset(from: tradeVM.symbol)
        )
    }

    /// 刷新底部持仓/委托/资产。
    func refreshBottom() {
        guard let tradeVM else { return }
        let tabs = isFutures ? VLTradeBottomTab.futuresTabs : VLTradeBottomTab.spotTabs
        var selected = tradeVM.bottomTabPublisher.value
        if !tabs.contains(selected) {
            selected = tabs[0]
        }
        bottomPanel.apply(
            snapshot: tradeVM.accountPublisher.value,
            tabs: tabs,
            selected: selected,
            isFutures: isFutures
        )
    }

    /// BTC/USDT → BTC。
    func baseAsset(from symbol: String) -> String {
        String(symbol.split(separator: "/").first ?? "BTC")
    }

    /// 滚动内容约束。
    func layoutContent() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        symbolBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(VLTradeLayout.symbolBarHeight)
        }
        timeframeBar.snp.makeConstraints {
            $0.top.equalTo(symbolBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(VLTradeLayout.timeframeHeight)
        }
        klineView.snp.makeConstraints {
            $0.top.equalTo(timeframeBar.snp.bottom).offset(4.rpx)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(VLTradeLayout.tradePanelKlineHeight)
        }
        formView.snp.makeConstraints {
            $0.top.equalTo(klineView.snp.bottom).offset(10.rpx)
            $0.leading.equalToSuperview().offset(VLTradeLayout.horizontalInset)
            $0.width.equalToSuperview().multipliedBy(VLTradeLayout.formWidthRatio)
                .offset(-VLTradeLayout.horizontalInset)
        }
        orderBookView.snp.makeConstraints {
            $0.top.equalTo(formView)
            $0.leading.equalTo(formView.snp.trailing).offset(10.rpx)
            $0.trailing.equalToSuperview().offset(-VLTradeLayout.horizontalInset)
            $0.bottom.equalTo(formView)
        }
        bottomPanel.snp.makeConstraints {
            $0.top.equalTo(formView.snp.bottom).offset(16.rpx)
            $0.leading.trailing.equalToSuperview().inset(VLTradeLayout.horizontalInset)
            $0.bottom.equalToSuperview().offset(-20.rpx)
        }
    }

    /// 滚动容器。
    func lazyScrollView() -> UIScrollView {
        UIScrollView().then {
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.keyboardDismissMode = .onDrag
        }.make(self) { _ in }
    }

    /// 内容根。
    func lazyContentView() -> UIView {
        UIView().then {
            $0.backgroundColor = VLTradeAppearance.pageBackground
        }.make(scrollView) { _ in }
    }

    /// 交易对栏。
    func lazySymbolBar() -> VLTradeSymbolBarView {
        VLTradeSymbolBarView().then { $0.show() }.make(contentView) { _ in }
    }

    /// 周期栏。
    func lazyTimeframeBar() -> VLTradeTimeframeBar {
        VLTradeTimeframeBar().then { $0.show() }.make(contentView) { _ in }
    }

    /// K 线。
    func lazyKLineView() -> VLTradeKLineView {
        VLTradeKLineView().then { $0.show() }.make(contentView) { _ in }
    }

    /// 左侧表单。
    func lazyFormView() -> VLTradeOrderFormView {
        VLTradeOrderFormView().then { $0.show() }.make(contentView) { _ in }
    }

    /// 右侧盘口。
    func lazyOrderBookView() -> VLTradeOrderBookView {
        VLTradeOrderBookView().then { $0.show() }.make(contentView) { _ in }
    }

    /// 底部持仓/委托/资产。
    func lazyBottomPanel() -> VLTradeBottomPanelView {
        VLTradeBottomPanelView().then { $0.show() }.make(contentView) { _ in }
    }
}
