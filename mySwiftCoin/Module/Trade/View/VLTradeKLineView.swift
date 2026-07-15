import UIKit
import SnapKit
import Then
import Stockee

/// Stockee K 线适配视图：蜡烛 / 分时 + MA + 成交量。
final class VLTradeKLineView: UIView {

    /// Stockee 图表（泛型蜡烛）。
    private lazy var chartView = lazyChartView()
    /// 避免每次 reload 重建 descriptor。
    private var lastIsTimeShare: Bool?

    /// 配置深色主题与 descriptor。
    func show() {
        backgroundColor = VLTradeAppearance.pageBackground
        _ = chartView
        applyOKXStyle()
        configureDescriptor(isTimeShare: false)
        lastIsTimeShare = false
    }

    /// 刷新蜡烛与周期（分时用 TimeShare，其余蜡烛）。
    func reload(candles: [VLTradeCandleModel], timeframe: VLTradeTimeframe) {
        let isTimeShare = timeframe.isTimeShare
        if lastIsTimeShare != isTimeShare {
            configureDescriptor(isTimeShare: isTimeShare)
            lastIsTimeShare = isTimeShare
        }
        chartView.reloadData(Self.toChartCandles(candles))
        scrollToEndIfNeeded()
    }

    /// 领域蜡烛 → Stockee Quote；供测试与 reload 共用。
    static func toChartCandles(_ candles: [VLTradeCandleModel]) -> [VLTradeChartCandle] {
        VLTradeMapper.toStockeeQuotes(candles).map {
            VLTradeChartCandle(
                date: $0.date,
                open: $0.open,
                high: $0.high,
                low: $0.low,
                close: $0.close,
                volume: $0.volume
            )
        }
    }
}

/// 符合 Stockee `Quote` 的蜡烛适配类型。
struct VLTradeChartCandle: Quote {
    var date: Date
    var open: CGFloat
    var high: CGFloat
    var low: CGFloat
    var close: CGFloat
    var volume: CGFloat
}

fileprivate extension VLTradeKLineView {

    /// 构建 ChartView 并贴满。
    func lazyChartView() -> ChartView<VLTradeChartCandle> {
        ChartView<VLTradeChartCandle>().then {
            $0.backgroundColor = VLTradeAppearance.pageBackground
            // 右侧留给最新价标签 / Y 轴，避免盖住蜡烛
            $0.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: Self.rightPriceInset)
            $0.showsHorizontalScrollIndicator = false
        }.make(self) {
            $0.edges.equalToSuperview()
        }
    }

    /// 右侧价格栏宽度（含与蜡烛的间距）。
    static let rightPriceInset: CGFloat = 84
    /// 最新价标签相对主图右缘的额外间距。
    static let priceLabelGap: CGFloat = 10

    /// OKX 涨绿跌红。
    func applyOKXStyle() {
        chartView.configuration.upColor = VLTradeAppearance.up
        chartView.configuration.downColor = VLTradeAppearance.down
        chartView.configuration.captionPadding.right = Self.rightPriceInset
        chartView.configuration.barWidth = 5
        chartView.configuration.spacing = 1
    }

    /// 组装主图 + 成交量 + 时间轴（交易页紧凑高度）。
    func configureDescriptor(isTimeShare: Bool) {
        chartView.descriptor = ChartDescriptor(spacing: 4) {
            ChartGroup(height: VLTradeLayout.klineMainHeightCompact) {
                GridIndicator(lineWidth: 1 / UIScreen.main.scale, color: VLTradeAppearance.elevated)
                YAxisAnnotation(maxWidth: Self.rightPriceInset)
                if isTimeShare {
                    TimeShareChart(color: VLTradeAppearance.up)
                } else {
                    CandlestickChart()
                    MAChart(configuration: MAConfiguration(period: 5, color: ColorFromHex(0xF0B90B)))
                    MAChart(configuration: MAConfiguration(period: 10, color: ColorFromHex(0xB47BFF)))
                    MAChart(configuration: MAConfiguration(period: 20, color: ColorFromHex(0x5B8CFF)))
                }
                LatestPriceIndicator(
                    height: 14,
                    minWidth: 40,
                    maxWidth: Self.rightPriceInset - Self.priceLabelGap - 4,
                    textColor: .white,
                    trailingGap: Self.priceLabelGap
                )
            }
            ChartGroup(height: VLTradeLayout.klineVolumeHeightCompact) {
                GridIndicator(lineWidth: 1 / UIScreen.main.scale, color: VLTradeAppearance.elevated)
                YAxisAnnotation(maxWidth: Self.rightPriceInset)
                VolumeChart()
            }
            ChartGroup(height: VLTradeLayout.klineTimeHeightCompact) {
                TimeAnnotation(dateFormat: "HH:mm")
                SelectedTimeIndicator(
                    backgroundColor: VLTradeAppearance.elevated,
                    textColor: VLTradeAppearance.textPrimary
                )
            }
        }
    }

    /// 滚动到最新一根。
    func scrollToEndIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let inset = self.chartView.contentInset.right
            let offsetX = max(0, self.chartView.contentSize.width - self.chartView.bounds.width + inset)
            self.chartView.setContentOffset(CGPoint(x: offsetX, y: -self.chartView.contentInset.top), animated: false)
        }
    }
}
