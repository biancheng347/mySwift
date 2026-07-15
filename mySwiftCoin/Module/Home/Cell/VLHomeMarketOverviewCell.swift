import UIKit
import SnapKit
import Then

/// 行情概况：标题行带右箭头 + 三列横排统计（共享背景）+ 宏观事件。
final class VLHomeMarketOverviewCell: BaseCVCell {

    private lazy var titleLabel = lazyTitleLabel()
    private lazy var arrowView = lazyArrowView()
    private lazy var cardsBackground = lazyCardsBackground()
    private lazy var cardsStack = lazyCardsStack()
    private lazy var eventLabel = lazyEventLabel()

    /// 渲染概况标题、统计卡片与事件标题。
    override func cell(model: ItemTypeProtocol) {
        guard let item = model as? ItemTypeModel<VLHomeMarketOverviewModel> else { return }
        // 触达箭头与卡片栈，避免 lazy 未安装。
        _ = arrowView
        _ = cardsStack
        titleLabel.text = item.data.title
        eventLabel.text = item.data.eventTitle
        eventLabel.isHidden = item.data.eventTitle.isEmpty
        rebuildCards(item.data.cards)
    }
}

fileprivate extension VLHomeMarketOverviewCell {

    /// 分区标题标签。
    func lazyTitleLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = VLHomeAppearance.textPrimary
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(overviewTapped))
            )
        }.make(contentView) {
            $0.leading.equalToSuperview().offset(VLHomeLayout.horizontalInset)
            $0.top.equalToSuperview().offset(8.rpx)
            $0.trailing.equalToSuperview().offset(-(VLHomeLayout.horizontalInset + 24.rpx))
        }
    }

    /// 标题行右侧披露箭头。
    func lazyArrowView() -> UIImageView {
        UIImageView(
            image: UIImage(systemName: "chevron.right")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
        ).then {
            $0.tintColor = VLHomeAppearance.textTertiary
            $0.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(overviewTapped))
            )
        }.make(contentView) {
            $0.trailing.equalToSuperview().offset(-VLHomeLayout.horizontalInset)
            $0.centerY.equalTo(titleLabel)
            $0.width.height.equalTo(16.rpx)
        }
    }

    /// 三列统计共享的表面背景容器。
    func lazyCardsBackground() -> UIView {
        UIView().then {
            $0.backgroundColor = VLHomeAppearance.surface
            $0.layer.cornerRadius = 8.rpx
        }.make(contentView) {
            $0.leading.trailing.equalToSuperview().inset(VLHomeLayout.horizontalInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8.rpx)
            $0.height.equalTo(72.rpx)
        }
    }

    /// 一行三列的等宽统计栈。
    func lazyCardsStack() -> UIStackView {
        UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 0
            $0.distribution = .fillEqually
            $0.alignment = .fill
        }.make(cardsBackground) {
            $0.edges.equalToSuperview()
        }
    }

    /// 卡片下方的宏观事件标题。
    func lazyEventLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = VLHomeAppearance.textSecondary
            $0.numberOfLines = 2
        }.make(contentView) {
            $0.leading.trailing.equalToSuperview().inset(VLHomeLayout.horizontalInset)
            $0.top.equalTo(cardsBackground.snp.bottom).offset(8.rpx)
            $0.bottom.lessThanOrEqualToSuperview().offset(-4.rpx)
        }
    }

    /// 按三列重建统计项（超出部分自动换行到下一行背景内不支持，仅取前 3 个或按行填充）。
    func rebuildCards(_ cards: [VLHomeMarketOverviewCardModel]) {
        cardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // 一行展示 3 个；不足用空位补齐以保持等宽。
        let display = Array(cards.prefix(3))
        (0..<3).forEach { index in
            if index < display.count {
                cardsStack.addArrangedSubview(makeMetricView(display[index]))
            } else {
                cardsStack.addArrangedSubview(UIView())
            }
        }
    }

    /// 构建单列概况指标（无独立背景，依赖共享容器）。
    func makeMetricView(_ card: VLHomeMarketOverviewCardModel) -> UIView {
        UIView().then { container in
            UILabel().then {
                $0.text = card.label
                $0.font = .systemFont(ofSize: 12)
                $0.textColor = VLHomeAppearance.textSecondary
                $0.textAlignment = .center
            }.make(container) {
                $0.leading.trailing.equalToSuperview().inset(4.rpx)
                $0.top.equalToSuperview().offset(10.rpx)
            }
            UILabel().then {
                $0.text = card.value
                $0.font = .systemFont(ofSize: 14, weight: .semibold)
                $0.textColor = VLHomeAppearance.textPrimary
                $0.textAlignment = .center
                $0.adjustsFontSizeToFitWidth = true
                $0.minimumScaleFactor = 0.75
            }.make(container) {
                $0.leading.trailing.equalToSuperview().inset(4.rpx)
                $0.centerY.equalToSuperview().offset(2.rpx)
            }
            let footerText: String?
            let footerColor: UIColor
            if let change = card.changeText, let positive = card.isChangePositive {
                footerText = change
                footerColor = positive ? VLHomeAppearance.up : VLHomeAppearance.down
            } else if let coin = card.coinName {
                footerText = coin
                footerColor = VLHomeAppearance.textTertiary
            } else {
                footerText = nil
                footerColor = VLHomeAppearance.textTertiary
            }
            if let footerText {
                UILabel().then {
                    $0.text = footerText
                    $0.font = .systemFont(ofSize: 11, weight: .medium)
                    $0.textColor = footerColor
                    $0.textAlignment = .center
                }.make(container) {
                    $0.leading.trailing.equalToSuperview().inset(4.rpx)
                    $0.bottom.equalToSuperview().offset(-10.rpx)
                }
            }
        }
    }

    /// 通过 VM 处理概况标题 / 箭头点击。
    @objc func overviewTapped() {
        weakView(fetch: VLHomeExchangeView.self)?.vm.onMarketOverviewTap()
    }
}
