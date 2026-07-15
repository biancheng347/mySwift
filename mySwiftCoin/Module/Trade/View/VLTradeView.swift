import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 交易 Tab 根视图：顶部分类点击切换页面，禁止左右滑动切页。
final class VLTradeView: UIView {

    fileprivate lazy var tradeVM = VLTradeVM()
    private lazy var categoryBar = lazyCategoryBar()
    private lazy var marketPanel = lazyMarketPanel()
    private lazy var convertPanel = lazyConvertPanel()
    private lazy var strategyPanel = lazyStrategyPanel()

    /// 供 Cell / 子视图 weakView 访问的 VM。
    var vm: VLTradeVM { tradeVM }

    /// 注册 WeakView、绑定并首次加载。
    func show() {
        weakView(register: self)
        backgroundColor = VLTradeAppearance.pageBackground
        _ = categoryBar
        _ = marketPanel
        _ = convertPanel
        _ = strategyPanel
        bind()
        updatePageVisibility(category: tradeVM.categoryPublisher.value)
        tradeVM.load()
    }
}

fileprivate extension VLTradeView {

    /// 绑定分类与显隐（点击切换，无 PageScroll）。
    func bind() {
        categoryBar.onSelect = weakHandle { this, category in
            this?.tradeVM.selectCategory(category)
        }
        tradeVM.categoryPublisher.asObservable()
            .observeOnThread(isMain: true)
            .subscribe(onNext: weakHandle { this, category in
                this?.categoryBar.applySelected(category)
                this?.updatePageVisibility(category: category)
                this?.marketPanel.applyMode(isFutures: category == .futures)
            })
            .disposed(by: disposeBag)
    }

    /// 按分类显示对应面板（isHidden，不滑动）。
    func updatePageVisibility(category: VLTradeCategory) {
        let showMarket = category.isMarketPanel
        marketPanel.isHidden = !showMarket
        convertPanel.isHidden = category != .convert
        strategyPanel.isHidden = category != .strategy
    }

    /// 顶部分类栏。
    func lazyCategoryBar() -> VLTradeCategoryBar {
        VLTradeCategoryBar().then { $0.show() }.make(self) {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(VLTradeLayout.categoryBarHeight)
        }
    }

    /// 现货/合约共用行情面板。
    func lazyMarketPanel() -> VLTradeMarketPanelView {
        VLTradeMarketPanelView().then {
            $0.show(vm: tradeVM, isFutures: false)
        }.make(self) {
            $0.top.equalTo(categoryBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    /// 闪兑占位。
    func lazyConvertPanel() -> VLTradePlaceholderPanelView {
        VLTradePlaceholderPanelView().then {
            $0.show(title: "闪兑", subtitle: "快速兑换资产，后续接入 OKX Convert")
            $0.isHidden = true
        }.make(self) {
            $0.top.equalTo(categoryBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    /// 策略占位。
    func lazyStrategyPanel() -> VLTradePlaceholderPanelView {
        VLTradePlaceholderPanelView().then {
            $0.show(title: "策略", subtitle: "交易机器人与策略广场即将上线")
            $0.isHidden = true
        }.make(self) {
            $0.top.equalTo(categoryBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
