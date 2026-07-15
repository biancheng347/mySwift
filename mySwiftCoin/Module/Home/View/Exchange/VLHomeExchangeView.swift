import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 交易所 Tab 列表容器，使用 `ItemListView` + 下拉刷新。
final class VLHomeExchangeView: UIView {

    fileprivate lazy var exchangeVM = VLHomeExchangeVM()
    fileprivate lazy var listView = lazyListView()
    fileprivate lazy var loadingView = lazyLoadingView()

    /// 供 VC / Cell 通过 weakView 访问的交易所 VM。
    var vm: VLHomeExchangeVM { exchangeVM }

    /// 绑定 VM、连接刷新并触发首次加载。
    func show() {
        weakView(register: self)
        backgroundColor = VLHomeAppearance.pageBackground
        _ = listView
        bind()
        exchangeVM.load()
    }
}

fileprivate extension VLHomeExchangeView {

    /// 将 Relay 连接到列表、刷新与加载遮罩。
    func bind() {
        exchangeVM.listPublisher.asObservable()
            .bind(dispose: disposeBag, result: weakHandle { this, items in
                this?.listView.proxyItemsReload(models: items)
            })
        exchangeVM.refresh.bind(dispose: disposeBag, collectionView: listView.collectionView)
        exchangeVM.loading.bind(dispose: disposeBag, weakLoading: weakHandle { this, loading in
            this?.loadingView.isHidden = !loading
            loading ? this?.loadingView.startAnimating() : this?.loadingView.stopAnimating()
        })
        exchangeVM.error.bind(dispose: disposeBag, weakError: { error in
            #if DEBUG
            print("[VLHomeExchangeView] load error: \(error.localizedDescription)")
            #endif
        })
    }

    /// 配置扁平 ItemListView 并注册全部首页 Cell。
    func lazyListView() -> ItemListView<ItemProxy> {
        ItemListView().then {
            $0.cells = [
                VLHomeSearchCell.self,
                VLHomeAssetsCell.self,
                VLHomeBannerCell.self,
                VLHomeMarketListCell.self,
                VLHomeMarketOverviewCell.self,
                VLHomeAnnouncementCell.self,
            ]
            $0.isHeaderRefresh = true
            $0.headerHandle = weakHandle { $0?.exchangeVM.load() }
        }.make(self) {
            $0.edges.equalToSuperview()
        }
    }

    /// 首次加载时的居中活动指示器。
    func lazyLoadingView() -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: .medium).then {
            $0.color = VLHomeAppearance.textPrimary
            $0.hidesWhenStopped = true
            $0.isHidden = true
        }.make(self) {
            $0.center.equalToSuperview()
        }
    }
}
