import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 首页根视图：导航分段 + 交易所 / Web3 页面切换。
final class VLHomeView: UIView {

    fileprivate lazy var vm = VLHomeVM()
    fileprivate lazy var navView = lazyNavView()
    fileprivate lazy var exchangeView = lazyExchangeView()
    fileprivate lazy var web3View = lazyWeb3View()

    /// 构建子视图、绑定 Tab 状态，默认显示交易所。
    func show() {
        weakView(register: self)
        backgroundColor = VLHomeAppearance.pageBackground
        _ = navView
        _ = exchangeView
        _ = web3View
        bind()
        updatePageVisibility(index: vm.currentTabIndex.value)
    }
}

fileprivate extension VLHomeView {

    /// 连接导航点击与 VM Tab Relay 到页面显隐。
    func bind() {
        navView.onTabSelected = weakHandle { this, index in
            this?.vm.selectTab(index)
        }
        vm.currentTabIndex.asObservable()
            .bind(dispose: disposeBag, result: weakHandle { this, index in
                this?.navView.updateSelection(index)
                this?.updatePageVisibility(index: index)
            })
    }

    /// 按选中索引显示交易所或 Web3 子页。
    func updatePageVisibility(index: Int) {
        exchangeView.isHidden = index != 0
        web3View.isHidden = index != 1
    }

    /// 顶部分段栏，钉在安全区域下方。
    func lazyNavView() -> VLHomeNavView {
        VLHomeNavView().then { $0.show() }.make(self) {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48.rpx)
        }
    }

    /// 导航下方的交易所列表页。
    func lazyExchangeView() -> VLHomeExchangeView {
        VLHomeExchangeView().then { $0.show() }.make(self) {
            $0.top.equalTo(navView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    /// 导航下方的 Web3 占位页。
    func lazyWeb3View() -> VLHomeWeb3View {
        VLHomeWeb3View().then { $0.show() }.make(self) {
            $0.top.equalTo(navView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
