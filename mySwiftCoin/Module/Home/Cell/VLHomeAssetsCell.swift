import UIKit
import SnapKit
import Then

/// 资产摘要：预估总资产层级 + 余额 + 盈亏 + 迷你折线。
final class VLHomeAssetsCell: BaseCVCell {

    private var chartLayer = CAShapeLayer()
    private var assetsModel: VLHomeAssetsModel?
    private var currentModel: VLHomeAssetsCurrencyModel?
    private var lastChartSize: CGSize = .zero

    private lazy var cardView = lazyCardView()
    private lazy var titleLabel = lazyTitleLabel()
    private lazy var symbolLabel = lazySymbolLabel()
    private lazy var toggleButton = lazyToggleButton()
    private lazy var totalLabel = lazyTotalLabel()
    private lazy var profitLabel = lazyProfitLabel()
    private lazy var chartContainer = lazyChartContainer()

    /// 用首个币种选项填充资产卡片。
    override func cell(model: ItemTypeProtocol) {
        guard let item = model as? ItemTypeModel<VLHomeAssetsModel>,
              let currency = item.data.currencies.first else { return }
        assetsModel = item.data
        currentModel = currency
        lastChartSize = .zero
        symbolLabel.text = currency.symbol
        refreshBalanceDisplay()
        profitLabel.text = "今日盈亏 \(currency.todayProfit) (\(currency.todayProfitRate))"
        profitLabel.textColor = currency.isProfitPositive ? VLHomeAppearance.up : VLHomeAppearance.down
        drawChart(points: currency.chartPoints, positive: currency.isProfitPositive)
    }

    /// 复用前清空本地 UI 引用。
    override func prepareForReuse() {
        super.prepareForReuse()
        assetsModel = nil
        currentModel = nil
        lastChartSize = .zero
    }

    /// 仅在折线区域尺寸变化时重绘。
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = chartContainer.bounds.size
        guard size.width > 0, size != lastChartSize, let currency = currentModel else { return }
        lastChartSize = size
        drawChart(points: currency.chartPoints, positive: currency.isProfitPositive)
    }
}

fileprivate extension VLHomeAssetsCell {

    /// 表面卡片容器。
    func lazyCardView() -> UIView {
        UIView().then {
            $0.backgroundColor = VLHomeAppearance.surface
            $0.layer.cornerRadius = 12.rpx
        }.make(contentView) {
            $0.leading.trailing.equalToSuperview().inset(VLHomeLayout.horizontalInset)
            $0.top.bottom.equalToSuperview().inset(8.rpx)
        }
    }

    /// 「预估总资产」层级标题。
    func lazyTitleLabel() -> UILabel {
        UILabel().then {
            $0.text = "预估总资产"
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = VLHomeAppearance.textSecondary
        }.make(cardView) {
            $0.top.leading.equalToSuperview().offset(VLHomeLayout.horizontalInset)
        }
    }

    /// 币种符号标签。
    func lazySymbolLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 12, weight: .medium)
            $0.textColor = VLHomeAppearance.textTertiary
        }.make(cardView) {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(6.rpx)
        }
    }

    /// 隐藏余额的眼睛切换按钮。
    func lazyToggleButton() -> UIButton {
        UIButton(type: .system).then {
            $0.tintColor = VLHomeAppearance.textSecondary
            $0.setImage(UIImage(systemName: "eye"), for: .normal)
            $0.addTarget(self, action: #selector(toggleBalance), for: .touchUpInside)
        }.make(cardView) {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(symbolLabel.snp.trailing).offset(6.rpx)
            $0.size.equalTo(22.rpx)
        }
    }

    /// 总余额数值标签。
    func lazyTotalLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 32, weight: .bold)
            $0.textColor = VLHomeAppearance.textPrimary
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.7
        }.make(cardView) {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8.rpx)
            $0.leading.equalToSuperview().offset(VLHomeLayout.horizontalInset)
            $0.trailing.lessThanOrEqualTo(chartContainer.snp.leading).offset(-12.rpx)
        }
    }

    /// 今日盈亏标签。
    func lazyProfitLabel() -> UILabel {
        UILabel().then {
            $0.font = .systemFont(ofSize: 13, weight: .medium)
        }.make(cardView) {
            $0.top.equalTo(totalLabel.snp.bottom).offset(6.rpx)
            $0.leading.equalToSuperview().offset(VLHomeLayout.horizontalInset)
            $0.trailing.lessThanOrEqualTo(chartContainer.snp.leading).offset(-12.rpx)
        }
    }

    /// 迷你折线绘制区域。
    func lazyChartContainer() -> UIView {
        UIView().then {
            $0.backgroundColor = .clear
        }.make(cardView) {
            $0.trailing.equalToSuperview().offset(-VLHomeLayout.horizontalInset)
            $0.centerY.equalToSuperview().offset(8.rpx)
            $0.width.equalTo(100.rpx)
            $0.height.equalTo(48.rpx)
        }
    }

    /// 通过 VM 切换余额掩码。
    @objc func toggleBalance() {
        weakView(fetch: VLHomeExchangeView.self)?.vm.toggleBalanceHidden()
    }

    /// 按模型隐藏状态更新总余额标签。
    func refreshBalanceDisplay() {
        guard let currency = currentModel, let assetsModel else { return }
        let hidden = assetsModel.isBalanceHidden
        let icon = hidden ? "eye.slash" : "eye"
        toggleButton.setImage(UIImage(systemName: icon), for: .normal)
        totalLabel.text = hidden ? "****" : currency.totalValue
    }

    /// 用 CAShapeLayer 绘制简易折线迷你图。
    func drawChart(points: [Double], positive: Bool) {
        chartLayer.removeFromSuperlayer()
        guard points.count >= 2 else { return }
        let minY = points.min() ?? 0
        let maxY = points.max() ?? 1
        let range = max(maxY - minY, 0.001)
        let width = chartContainer.bounds.width > 0 ? chartContainer.bounds.width : 100.rpx
        let height = chartContainer.bounds.height > 0 ? chartContainer.bounds.height : 48.rpx
        let path = UIBezierPath()
        points.enumerated().forEach { index, value in
            let x = CGFloat(index) / CGFloat(points.count - 1) * width
            let y = height - CGFloat((value - minY) / range) * height
            index == 0 ? path.move(to: CGPoint(x: x, y: y)) : path.addLine(to: CGPoint(x: x, y: y))
        }
        chartLayer.path = path.cgPath
        chartLayer.strokeColor = (positive ? VLHomeAppearance.up : VLHomeAppearance.down).cgColor
        chartLayer.fillColor = UIColor.clear.cgColor
        chartLayer.lineWidth = 1.5
        chartContainer.layer.addSublayer(chartLayer)
    }
}
