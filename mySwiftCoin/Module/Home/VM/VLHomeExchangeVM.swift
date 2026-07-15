import Foundation
import RxSwift
import RxCocoa
import RxRelay

/// 交易所 Tab 列表 VM：加载数据并发布给 BTCollectionView。
final class VLHomeExchangeVM: RxswiftRefresh, RxswiftError, RxswiftLoading,
                              DisposeProtocol, WeakHandleProtocol {

    /// 供 `ItemListView` 使用的扁平列表数据。
    private(set) lazy var listPublisher = BehaviorRelay<[ItemTypeProtocol]>(value: [])

    private let service: VLHomeExchangeService
    /// 触发加载；`flatMapLatest` 会自动取消上一次请求。
    private let loadTrigger = PublishRelay<Void>()

    /// 注入服务（默认 mock），并绑定一次性加载流水线。
    init(service: VLHomeExchangeService = VLHomeExchangeService()) {
        self.service = service
        bindLoad()
    }

    /// 拉取交易所分区列表。
    func load() {
        loadTrigger.accept(())
    }

    /// 切换资产余额掩码并刷新列表。
    func toggleBalanceHidden() {
        guard let item = assetsListItem else { return }
        item.data.isBalanceHidden.toggle()
        republishList()
    }

    /// 选中行情 Tab 并重置永续模式。
    func selectMarketTab(index: Int) {
        guard let item = marketListItem else { return }
        item.data.selectedTabIndex = index
        item.data.isSwapMode = false
        republishList()
    }

    /// 切换现货 / 永续模式。
    func selectMarketSwapMode(_ isSwap: Bool) {
        guard let item = marketListItem else { return }
        item.data.isSwapMode = isSwap
        republishList()
    }

    /// 搜索栏点击占位。
    func onSearchTap() {
        #if DEBUG
        print("[VLHomeExchangeVM] onSearchTap")
        #endif
    }

    /// Banner 点击占位。
    func onBannerTap(index: Int) {
        #if DEBUG
        print("[VLHomeExchangeVM] onBannerTap index: \(index)")
        #endif
    }

    /// 行情「查看更多」点击占位。
    func onMarketMoreTap() {
        #if DEBUG
        print("[VLHomeExchangeVM] onMarketMoreTap")
        #endif
    }

    /// 行情概况标题 / 箭头点击占位。
    func onMarketOverviewTap() {
        #if DEBUG
        print("[VLHomeExchangeVM] onMarketOverviewTap")
        #endif
    }

    /// 币种行点击占位。
    func onCoinRowTap(pair: String) {
        #if DEBUG
        print("[VLHomeExchangeVM] onCoinRowTap pair: \(pair)")
        #endif
    }

    /// 公告行点击占位。
    func onAnnouncementTap(index: Int) {
        #if DEBUG
        print("[VLHomeExchangeVM] onAnnouncementTap index: \(index)")
        #endif
    }
}

fileprivate extension VLHomeExchangeVM {

    /// 当前列表中的资产分区 Item。
    var assetsListItem: ItemTypeModel<VLHomeAssetsModel>? {
        listPublisher.value.compactMap { $0 as? ItemTypeModel<VLHomeAssetsModel> }.first
    }

    /// 当前列表中的行情列表分区 Item。
    var marketListItem: ItemTypeModel<VLHomeMarketListModel>? {
        listPublisher.value.compactMap { $0 as? ItemTypeModel<VLHomeMarketListModel> }.first
    }

    /// 重新发布当前列表以触发 Cell 重载。
    func republishList() {
        listPublisher.accept(listPublisher.value)
    }
}

fileprivate extension VLHomeExchangeVM {

    /// 将 loadTrigger 绑定到 disposeBag：新触发会取消上一次未完成的请求。
    func bindLoad() {
        loadTrigger
            .flatMapLatest(weakHandle { this, _ -> Observable<[ItemTypeProtocol]> in
                guard let this else { return .empty() }
                return this.service.getList()
                    .observeOnThread(isMain: true)
                    .map(toItems)
                    .trackError(this.error)
                    .trackLoading(this.loading)
                    .trackRefresh(this.refresh)
                    .catchAndReturn([])
            })
            .subscribe(onNext: weakHandle { this, items in
                this?.listPublisher.accept(items)
            })
            .disposed(by: disposeBag)
    }
}
