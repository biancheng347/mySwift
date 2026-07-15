import UIKit
import SnapKit
import Then

/// 闪兑 / 策略等非行情面板占位。
final class VLTradePlaceholderPanelView: UIView {

    private lazy var titleLabel = lazyTitleLabel()
    private lazy var subtitleLabel = lazySubtitleLabel()

    /// 展示占位文案。
    func show(title: String, subtitle: String) {
        backgroundColor = VLTradeAppearance.pageBackground
        titleLabel.text = title
        subtitleLabel.text = subtitle
        _ = titleLabel
        _ = subtitleLabel
    }
}

fileprivate extension VLTradePlaceholderPanelView {

    /// 主标题。
    func lazyTitleLabel() -> UILabel {
        UILabel().then {
            $0.textColor = VLTradeAppearance.textPrimary
            $0.font = .systemFont(ofSize: 20, weight: .semibold)
            $0.textAlignment = .center
        }.make(self) {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-12.rpx)
        }
    }

    /// 副文案。
    func lazySubtitleLabel() -> UILabel {
        UILabel().then {
            $0.textColor = VLTradeAppearance.textSecondary
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }.make(self) {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8.rpx)
            $0.leading.trailing.equalToSuperview().inset(32.rpx)
        }
    }
}
