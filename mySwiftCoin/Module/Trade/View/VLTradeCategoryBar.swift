import UIKit
import SnapKit
import Then

/// 交易顶部分类栏：仅点击切换，不承载水平滑动。
final class VLTradeCategoryBar: UIView {

    /// 分类点击回调。
    var onSelect: ((VLTradeCategory) -> Void)?

    private lazy var stack = lazyStack()
    private lazy var indicator = lazyIndicator()
    private var buttons: [UIButton] = []

    /// 搭建 Tab 并默认现货。
    func show() {
        backgroundColor = VLTradeAppearance.pageBackground
        _ = stack
        _ = indicator
        applySelected(.spot)
    }

    /// 同步选中态与指示条。
    func applySelected(_ category: VLTradeCategory) {
        buttons.enumerated().forEach { index, button in
            let selected = index == category.rawValue
            button.setTitleColor(
                selected ? VLTradeAppearance.textPrimary : VLTradeAppearance.textSecondary,
                for: .normal
            )
            button.titleLabel?.font = .systemFont(
                ofSize: selected ? 18 : 15,
                weight: selected ? .bold : .medium
            )
        }
        guard category.rawValue < buttons.count else { return }
        let target = buttons[category.rawValue]
        layoutIfNeeded()
        indicator.snp.remakeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalTo(target)
            $0.width.equalTo(18.rpx)
            $0.height.equalTo(2.5.rpx)
        }
        UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() }
    }
}

fileprivate extension VLTradeCategoryBar {

    /// 横向 Tab 行。
    func lazyStack() -> UIStackView {
        buttons = VLTradeCategory.allCases.map { category in
            UIButton(type: .system).then {
                $0.tag = category.rawValue
                $0.setTitle(category.title, for: .normal)
                $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
                $0.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 8, right: 4)
                $0.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            }
        }
        return UIStackView(arrangedSubviews: buttons).then {
            $0.axis = .horizontal
            $0.spacing = 22.rpx
            $0.alignment = .center
        }.make(self) {
            $0.leading.equalToSuperview().offset(VLTradeLayout.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(32.rpx)
        }
    }

    /// 选中指示条。
    func lazyIndicator() -> UIView {
        UIView().then {
            $0.backgroundColor = VLTradeAppearance.textPrimary
            $0.layer.cornerRadius = 1.25.rpx
        }.make(self) { _ in }
    }

    /// Tab 点击。
    @objc func tabTapped(_ sender: UIButton) {
        guard let category = VLTradeCategory(rawValue: sender.tag) else { return }
        onSelect?(category)
    }
}
