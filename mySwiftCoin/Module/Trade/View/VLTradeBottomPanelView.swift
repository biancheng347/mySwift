import UIKit
import SnapKit
import Then

/// OKX 风格底部区：Tab（持仓/委托/资产）+ mock 列表。
final class VLTradeBottomPanelView: UIView {

    /// Tab 切换回调。
    var onSelectTab: ((VLTradeBottomTab) -> Void)?

    private lazy var tabStack = lazyTabStack()
    private lazy var listStack = lazyListStack()
    private lazy var emptyLabel = lazyEmptyLabel()
    private var tabButtons: [UIButton] = []
    private var availableTabs: [VLTradeBottomTab] = VLTradeBottomTab.spotTabs
    private var selectedTab: VLTradeBottomTab = .openOrders

    /// 搭建底部区。
    func show() {
        backgroundColor = VLTradeAppearance.pageBackground
        _ = tabStack
        _ = listStack
        _ = emptyLabel
        rebuildTabs(VLTradeBottomTab.spotTabs, selected: .openOrders)
    }

    /// 按现货/合约刷新 Tab 与数据。
    func apply(
        snapshot: VLTradeAccountSnapshotModel,
        tabs: [VLTradeBottomTab],
        selected: VLTradeBottomTab,
        isFutures: Bool
    ) {
        if availableTabs != tabs || selectedTab != selected {
            rebuildTabs(tabs, selected: selected)
        }
        selectedTab = selected
        syncTabStyle()
        reloadList(snapshot: snapshot, tab: selected, isFutures: isFutures)
    }
}

fileprivate extension VLTradeBottomPanelView {

    /// 重建 Tab 行。
    func rebuildTabs(_ tabs: [VLTradeBottomTab], selected: VLTradeBottomTab) {
        availableTabs = tabs
        selectedTab = selected
        tabStack.arrangedSubviews.forEach {
            tabStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        tabButtons = tabs.map { tab in
            UIButton(type: .system).then {
                $0.setTitle(tab.title, for: .normal)
                $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
                $0.tag = tab.rawValue
                $0.contentEdgeInsets = UIEdgeInsets(top: 6, left: 4, bottom: 8, right: 12)
                $0.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            }
        }
        tabButtons.forEach { tabStack.addArrangedSubview($0) }
        syncTabStyle()
    }

    /// 选中态。
    func syncTabStyle() {
        tabButtons.forEach { button in
            let selected = button.tag == selectedTab.rawValue
            button.setTitleColor(
                selected ? VLTradeAppearance.textPrimary : VLTradeAppearance.textSecondary,
                for: .normal
            )
            button.titleLabel?.font = .systemFont(
                ofSize: selected ? 15 : 14,
                weight: selected ? .semibold : .medium
            )
        }
    }

    /// 刷新列表内容。
    func reloadList(
        snapshot: VLTradeAccountSnapshotModel,
        tab: VLTradeBottomTab,
        isFutures: Bool
    ) {
        listStack.arrangedSubviews.forEach {
            listStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        switch tab {
        case .positions:
            snapshot.positions.forEach {
                listStack.addArrangedSubview(VLTradeBottomCards.positionCard($0))
            }
            emptyLabel.isHidden = !snapshot.positions.isEmpty
            emptyLabel.text = "暂无持仓"
        case .openOrders:
            snapshot.openOrders.forEach {
                listStack.addArrangedSubview(VLTradeBottomCards.orderCard($0))
            }
            emptyLabel.isHidden = !snapshot.openOrders.isEmpty
            emptyLabel.text = "暂无委托"
        case .assets:
            snapshot.assets.forEach {
                listStack.addArrangedSubview(VLTradeBottomCards.assetCard($0))
            }
            emptyLabel.isHidden = !snapshot.assets.isEmpty
            emptyLabel.text = "暂无资产"
        }
        _ = isFutures
    }

    /// Tab 行。
    func lazyTabStack() -> UIStackView {
        UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 16.rpx
            $0.alignment = .center
        }.make(self) {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.equalTo(VLTradeLayout.bottomTabHeight)
        }
    }

    /// 列表竖栈。
    func lazyListStack() -> UIStackView {
        UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 10.rpx
            $0.alignment = .fill
        }.make(self) {
            $0.top.equalTo(tabStack.snp.bottom).offset(8.rpx)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    /// 空态。
    func lazyEmptyLabel() -> UILabel {
        UILabel().then {
            $0.text = "暂无数据"
            $0.textColor = VLTradeAppearance.textTertiary
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textAlignment = .center
            $0.isHidden = true
        }.make(self) {
            $0.top.equalTo(tabStack.snp.bottom).offset(24.rpx)
            $0.centerX.equalToSuperview()
        }
    }

    /// Tab 点击。
    @objc func tabTapped(_ sender: UIButton) {
        guard let tab = VLTradeBottomTab(rawValue: sender.tag) else { return }
        onSelectTab?(tab)
    }
}
