import UIKit
import SnapKit
import Then

/// 带 Tab + 列头的行情排行，最多 5 行币种子视图。
final class VLHomeMarketListCell: BaseCVCell {

    private var listModel: VLHomeMarketListModel?
    private var rowViews: [VLHomeMarketCoinRowView] = []

    private lazy var cardView = lazyCardView()
    private lazy var tabStack = lazyTabStack()
    private lazy var toggleStack = lazyToggleStack()
    private lazy var spotButton = lazyModeButton(title: "现货", tag: 0)
    private lazy var swapButton = lazyModeButton(title: "永续", tag: 1)
    private lazy var columnHeader = lazyColumnHeader()
    private lazy var rowsStack = lazyRowsStack()
    private lazy var moreButton = lazyMoreButton()

    /// 配置 Tab 并加载当前选中 Tab 的行。
    override func cell(model: ItemTypeProtocol) {
        guard let item = model as? ItemTypeModel<VLHomeMarketListModel> else { return }
        listModel = item.data
        // lazy moreButton 必须触达一次，否则「查看更多」不会加入视图树。
        _ = moreButton
        rebuildTabs()
        reloadRows()
    }
}

fileprivate extension VLHomeMarketListCell {

    /// 包裹行情列表 UI 的表面卡片。
    func lazyCardView() -> UIView {
        UIView().then {
            $0.backgroundColor = VLHomeAppearance.surface
            $0.layer.cornerRadius = 12.rpx
        }.make(contentView) {
            $0.leading.trailing.equalToSuperview().inset(VLHomeLayout.horizontalInset)
            $0.top.bottom.equalToSuperview().inset(8.rpx)
        }
    }

    /// 水平 Tab 标题按钮行。
    func lazyTabStack() -> UIStackView {
        UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 16.rpx
            $0.alignment = .center
        }.make(cardView) {
            $0.leading.equalToSuperview().offset(VLHomeLayout.horizontalInset)
            $0.top.equalToSuperview().offset(12.rpx)
            $0.height.equalTo(28.rpx)
        }
    }

    /// 现货 / 永续切换行（Tab 无 swap 时隐藏）。
    func lazyToggleStack() -> UIStackView {
        UIStackView(arrangedSubviews: [spotButton, swapButton]).then {
            $0.axis = .horizontal
            $0.spacing = 8.rpx
            $0.isHidden = true
        }.make(cardView) {
            $0.trailing.equalToSuperview().offset(-VLHomeLayout.horizontalInset)
            $0.centerY.equalTo(tabStack)
        }
    }

    /// OKX 三列列头：名称 / 最新价 / 涨跌幅。
    func lazyColumnHeader() -> UIView {
        UIView().then { header in
            let name = UILabel().then {
                $0.text = VLHomeLayout.columnNameTitle
                $0.font = .systemFont(ofSize: 12)
                $0.textColor = VLHomeAppearance.textTertiary
            }
            let price = UILabel().then {
                $0.text = VLHomeLayout.columnPriceTitle
                $0.font = .systemFont(ofSize: 12)
                $0.textColor = VLHomeAppearance.textTertiary
                $0.textAlignment = .right
            }
            let change = UILabel().then {
                $0.text = VLHomeLayout.columnChangeTitle
                $0.font = .systemFont(ofSize: 12)
                $0.textColor = VLHomeAppearance.textTertiary
                $0.textAlignment = .center
            }
            name.make(header) {
                $0.leading.equalToSuperview().offset(VLHomeLayout.horizontalInset)
                $0.centerY.equalToSuperview()
            }
            change.make(header) {
                $0.trailing.equalToSuperview().offset(-VLHomeLayout.horizontalInset)
                $0.centerY.equalToSuperview()
                $0.width.equalTo(VLHomeLayout.changeBadgeWidth)
            }
            price.make(header) {
                $0.trailing.equalTo(change.snp.leading).offset(-12.rpx)
                $0.centerY.equalToSuperview()
            }
        }.make(cardView) {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(tabStack.snp.bottom).offset(4.rpx)
            $0.height.equalTo(VLHomeLayout.columnHeaderHeight)
        }
    }

    /// 币种行子视图垂直栈（最多 5 行）。
    func lazyRowsStack() -> UIStackView {
        UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 0
        }.make(cardView) {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(columnHeader.snp.bottom)
        }
    }

    /// 「查看更多」操作按钮（居中，半圆角背景）。
    func lazyMoreButton() -> UIButton {
        UIButton(type: .system).then {
            $0.setTitle("查看更多", for: .normal)
            $0.setTitleColor(VLHomeAppearance.textSecondary, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            $0.backgroundColor = VLHomeAppearance.elevated
            $0.layer.cornerRadius = 16.rpx
            $0.clipsToBounds = true
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20.rpx, bottom: 0, right: 20.rpx)
            $0.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        }.make(cardView) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(rowsStack.snp.bottom).offset(8.rpx)
            $0.height.equalTo(32.rpx)
            $0.bottom.equalToSuperview().offset(-12.rpx)
        }
    }

    /// 创建现货 / 永续模式芯片。
    func lazyModeButton(title: String, tag: Int) -> UIButton {
        UIButton(type: .system).then {
            $0.tag = tag
            $0.setTitle(title, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            $0.layer.cornerRadius = 12.rpx
            $0.contentEdgeInsets = UIEdgeInsets(top: 4.rpx, left: 10.rpx, bottom: 4.rpx, right: 10.rpx)
            $0.addTarget(self, action: #selector(modeTapped(_:)), for: .touchUpInside)
        }
    }

    /// 根据模型重建 Tab 标题按钮。
    func rebuildTabs() {
        guard let listModel else { return }
        let tabs = listModel.tabs
        let selectedTabIndex = listModel.selectedTabIndex
        tabStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tabs.enumerated().forEach { index, tab in
            let selected = index == selectedTabIndex
            let button = UIButton(type: .system).then {
                $0.tag = index
                $0.setTitle(tab.title, for: .normal)
                $0.titleLabel?.font = .systemFont(ofSize: 15, weight: selected ? .semibold : .regular)
                $0.setTitleColor(
                    selected ? VLHomeAppearance.textPrimary : VLHomeAppearance.textSecondary,
                    for: .normal
                )
                $0.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            }
            tabStack.addArrangedSubview(button)
        }
        let currentTab = tabs[safe: selectedTabIndex]
        toggleStack.isHidden = !(currentTab?.showSpotSwapToggle ?? false)
        updateModeButtons()
    }

    /// 加载当前 Tab 与模式下最多 5 行。
    func reloadRows() {
        rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rowViews.removeAll()
        guard let listModel else { return }
        let tabs = listModel.tabs
        let selectedTabIndex = listModel.selectedTabIndex
        let isSwapMode = listModel.isSwapMode
        guard let tab = tabs[safe: selectedTabIndex] else { return }
        let rows = isSwapMode ? tab.swapRows : tab.spotRows
        rows.prefix(5).forEach { row in
            let view = VLHomeMarketCoinRowView()
            view.configure(with: row)
            view.applyChangeBackground(positive: row.isChangePositive)
            view.snp.makeConstraints { $0.height.equalTo(VLHomeLayout.coinRowHeight) }
            view.isUserInteractionEnabled = true
            view.accessibilityIdentifier = row.pair
            view.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(coinRowTapped(_:)))
            )
            rowsStack.addArrangedSubview(view)
            rowViews.append(view)
        }
    }

    /// 更新现货 / 永续芯片高亮。
    func updateModeButtons() {
        guard let listModel else { return }
        let isSwapMode = listModel.isSwapMode
        spotButton.backgroundColor = !isSwapMode ? VLHomeAppearance.elevated : .clear
        swapButton.backgroundColor = isSwapMode ? VLHomeAppearance.elevated : .clear
        spotButton.setTitleColor(!isSwapMode ? VLHomeAppearance.textPrimary : VLHomeAppearance.textSecondary, for: .normal)
        swapButton.setTitleColor(isSwapMode ? VLHomeAppearance.textPrimary : VLHomeAppearance.textSecondary, for: .normal)
    }

    /// 通过 VM 切换 Tab。
    @objc func tabTapped(_ sender: UIButton) {
        weakView(fetch: VLHomeExchangeView.self)?.vm.selectMarketTab(index: sender.tag)
    }

    /// 通过 VM 切换现货 / 永续模式。
    @objc func modeTapped(_ sender: UIButton) {
        weakView(fetch: VLHomeExchangeView.self)?.vm.selectMarketSwapMode(sender.tag == 1)
    }

    /// 通过 VM 处理「查看更多」点击。
    @objc func moreTapped() {
        weakView(fetch: VLHomeExchangeView.self)?.vm.onMarketMoreTap()
    }

    /// 通过 VM 处理币种行点击。
    @objc func coinRowTapped(_ gesture: UITapGestureRecognizer) {
        guard let pair = gesture.view?.accessibilityIdentifier else { return }
        weakView(fetch: VLHomeExchangeView.self)?.vm.onCoinRowTap(pair: pair)
    }
}

private extension Array {
    /// Tab 索引的越界安全下标。
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
