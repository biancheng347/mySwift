import UIKit
import SnapKit
import Then

/// OKX 风格 K 线周期 chips。
final class VLTradeTimeframeBar: UIView {

    /// 选中回调。
    var onSelect: ((VLTradeTimeframe) -> Void)?

    private lazy var stackView = lazyStackView()
    private var buttons: [UIButton] = []

    /// 初始化 chips。
    func show() {
        backgroundColor = VLTradeAppearance.pageBackground
        _ = stackView
        applySelected(.default)
    }

    /// 同步选中态。
    func applySelected(_ timeframe: VLTradeTimeframe) {
        let cases = VLTradeTimeframe.allCases
        for (index, button) in buttons.enumerated() where index < cases.count {
            let selected = cases[index] == timeframe
            button.isSelected = selected
            button.backgroundColor = selected ? VLTradeAppearance.chipSelected : VLTradeAppearance.chipNormal
            button.setTitleColor(
                selected ? VLTradeAppearance.textPrimary : VLTradeAppearance.textSecondary,
                for: .normal
            )
        }
    }
}

fileprivate extension VLTradeTimeframeBar {

    /// 横向 chips 栈。
    func lazyStackView() -> UIStackView {
        let cases = VLTradeTimeframe.allCases
        buttons = cases.enumerated().map { index, frame in
            UIButton(type: .system).then {
                $0.setTitle(frame.rawValue, for: .normal)
                $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
                $0.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
                $0.layer.cornerRadius = VLTradeLayout.buttonCornerRadius
                $0.tag = index
                $0.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
            }
        }
        return UIStackView(arrangedSubviews: buttons).then {
            $0.axis = .horizontal
            $0.spacing = 6.rpx
            $0.alignment = .center
            $0.distribution = .fill
        }.make(self) {
            $0.leading.equalToSuperview().offset(VLTradeLayout.horizontalInset)
            $0.trailing.lessThanOrEqualToSuperview().offset(-VLTradeLayout.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(28.rpx)
        }
    }

    /// chip 点击转发 VM。
    @objc func chipTapped(_ sender: UIButton) {
        let cases = VLTradeTimeframe.allCases
        guard sender.tag >= 0, sender.tag < cases.count else { return }
        onSelect?(cases[sender.tag])
    }
}
