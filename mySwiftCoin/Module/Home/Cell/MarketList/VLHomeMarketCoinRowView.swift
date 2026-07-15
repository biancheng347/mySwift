import UIKit
import SnapKit
import Then

/// `VLHomeMarketListCell` 内单行：名称左 / 最新价右对齐 / 涨跌幅固定宽居中。
final class VLHomeMarketCoinRowView: UIView {

    private lazy var pairLabel = lazyPairLabel()
    private lazy var tagLabel = lazyTagLabel()
    private lazy var volumeLabel = lazyVolumeLabel()
    private lazy var priceLabel = lazyPriceLabel()
    private lazy var subPriceLabel = lazySubPriceLabel()
    private lazy var changeLabel = lazyChangeLabel()

    /// 构建行内子视图。
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = pairLabel
        _ = tagLabel
        _ = volumeLabel
        _ = priceLabel
        _ = subPriceLabel
        _ = changeLabel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 用 coin 模型填充行标签。
    func configure(with row: VLHomeMarketCoinRowModel) {
        pairLabel.text = row.pair
        volumeLabel.text = row.volumeText
        priceLabel.text = row.priceText
        subPriceLabel.text = row.subPriceText
        changeLabel.text = row.changeText
        changeLabel.textColor = VLHomeAppearance.textOnBadge
        if let tag = row.tag, !tag.isEmpty {
            tagLabel.isHidden = false
            tagLabel.text = " \(tag) "
        } else {
            tagLabel.isHidden = true
        }
    }

    /// 配置完成后为涨跌幅标签设置实心底色（OKX 风格）。
    func applyChangeBackground(positive: Bool) {
        changeLabel.backgroundColor = positive ? VLHomeAppearance.up : VLHomeAppearance.down
    }
}

fileprivate extension VLHomeMarketCoinRowView {

    /// 交易对名称。
    func lazyPairLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 15, weight: .semibold)
            $0.textColor = VLHomeAppearance.textPrimary
        }.make(self) {
            $0.leading.equalToSuperview().offset(VLHomeLayout.horizontalInset)
            $0.top.equalToSuperview().offset(8.rpx)
        }
    }

    /// 可选永续标签芯片。
    func lazyTagLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 10, weight: .medium)
            $0.textColor = VLHomeAppearance.up
            $0.backgroundColor = VLHomeAppearance.actionGreen
            $0.layer.cornerRadius = 3.rpx
            $0.clipsToBounds = true
            $0.textAlignment = .center
            $0.isHidden = true
        }.make(self) {
            $0.leading.equalTo(pairLabel.snp.trailing).offset(6.rpx)
            $0.centerY.equalTo(pairLabel)
            $0.height.equalTo(16.rpx)
            $0.width.greaterThanOrEqualTo(28.rpx)
            $0.trailing.lessThanOrEqualTo(priceLabel.snp.leading).offset(-8.rpx)
        }
    }

    /// 24h 成交量副标题。
    func lazyVolumeLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 11)
            $0.textColor = VLHomeAppearance.textTertiary
        }.make(self) {
            $0.leading.equalToSuperview().offset(VLHomeLayout.horizontalInset)
            $0.top.equalTo(pairLabel.snp.bottom).offset(2.rpx)
            $0.trailing.lessThanOrEqualTo(priceLabel.snp.leading).offset(-8.rpx)
        }
    }

    /// 主价格列（右对齐，贴涨跌徽章左侧）。
    func lazyPriceLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 15, weight: .medium)
            $0.textColor = VLHomeAppearance.textPrimary
            $0.textAlignment = .right
        }.make(self) {
            $0.trailing.equalTo(changeLabel.snp.leading).offset(-12.rpx)
            $0.centerY.equalToSuperview().offset(-7.rpx)
            $0.width.greaterThanOrEqualTo(80.rpx)
        }
    }

    /// 价格下方法币等价。
    func lazySubPriceLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 11)
            $0.textColor = VLHomeAppearance.textTertiary
            $0.textAlignment = .right
        }.make(self) {
            $0.trailing.equalTo(priceLabel)
            $0.top.equalTo(priceLabel.snp.bottom).offset(2.rpx)
        }
    }

    /// 涨跌幅徽章：固定宽、文字居中、实心底。
    func lazyChangeLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 13, weight: .semibold)
            $0.textAlignment = .center
            $0.textColor = VLHomeAppearance.textOnBadge
            $0.layer.cornerRadius = 4.rpx
            $0.clipsToBounds = true
        }.make(self) {
            $0.trailing.equalToSuperview().offset(-VLHomeLayout.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(VLHomeLayout.changeBadgeWidth)
            $0.height.equalTo(VLHomeLayout.changeBadgeHeight)
        }
    }
}
