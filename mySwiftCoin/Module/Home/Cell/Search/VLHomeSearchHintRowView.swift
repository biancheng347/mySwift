import UIKit
import SnapKit
import Then

/// 搜索栏右侧单条提示行：可选 trailing icon + 文案。
final class VLHomeSearchHintRowView: UIView {

    private lazy var stack = lazyStack()
    private lazy var iconView = lazyIconView()
    private lazy var textLabel = lazyTextLabel()

    /// 按展示快照渲染右侧内容（icon+文字 或 纯文字）。
    func configure(_ display: VLHomeSearchHintDisplay) {
        _ = stack
        textLabel.text = display.text
        if let iconName = display.trailingIconName {
            iconView.image = UIImage(systemName: iconName)
            iconView.isHidden = false
        } else {
            iconView.image = nil
            iconView.isHidden = true
        }
    }
}

fileprivate extension VLHomeSearchHintRowView {

    /// 水平排列：可选图标 + 文案（隐藏图标时自动收紧间距）。
    func lazyStack() -> UIStackView {
        UIStackView(arrangedSubviews: [iconView, textLabel]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 4.rpx
        }.make(self) {
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.centerY.equalToSuperview()
        }
    }

    /// 右侧可选伴随图标。
    func lazyIconView() -> UIImageView {
        UIImageView().then {
            $0.tintColor = VLHomeAppearance.textSecondary
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
            $0.snp.makeConstraints { $0.size.equalTo(14.rpx) }
        }
    }

    /// 提示文案。
    func lazyTextLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = VLHomeAppearance.textSecondary
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }
}
