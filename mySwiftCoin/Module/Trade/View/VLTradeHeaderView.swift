import UIKit
import SnapKit
import Then

/// OKX 风格交易对 Header：价格 + 涨跌 + 高开低量。
final class VLTradeHeaderView: UIView {

    private lazy var symbolLabel = lazySymbolLabel()
    private lazy var priceLabel = lazyPriceLabel()
    private lazy var changeLabel = lazyChangeLabel()
    private lazy var statsLabel = lazyStatsLabel()

    /// 初始化布局。
    func show() {
        backgroundColor = VLTradeAppearance.pageBackground
        _ = symbolLabel
        _ = priceLabel
        _ = changeLabel
        _ = statsLabel
    }

    /// 用 ticker 刷新展示。
    func apply(ticker: VLTradeTickerModel) {
        symbolLabel.text = ticker.symbol
        priceLabel.text = ticker.lastPrice
        priceLabel.textColor = ticker.isUp ? VLTradeAppearance.up : VLTradeAppearance.down
        changeLabel.text = ticker.changePercent
        changeLabel.textColor = ticker.isUp ? VLTradeAppearance.up : VLTradeAppearance.down
        statsLabel.text = "高 \(ticker.high24h)  低 \(ticker.low24h)  量 \(ticker.volume24h)"
    }
}

fileprivate extension VLTradeHeaderView {

    /// 交易对名称。
    func lazySymbolLabel() -> UILabel {
        UILabel().then {
            $0.text = "BTC/USDT"
            $0.textColor = VLTradeAppearance.textPrimary
            $0.font = .systemFont(ofSize: 18, weight: .semibold)
        }.make(self) {
            $0.top.equalToSuperview().offset(8.rpx)
            $0.leading.equalToSuperview().offset(VLTradeLayout.horizontalInset)
        }
    }

    /// 最新价。
    func lazyPriceLabel() -> UILabel {
        UILabel().then {
            $0.text = "--"
            $0.textColor = VLTradeAppearance.up
            $0.font = .systemFont(ofSize: 28, weight: .bold)
        }.make(self) {
            $0.top.equalTo(symbolLabel.snp.bottom).offset(6.rpx)
            $0.leading.equalTo(symbolLabel)
        }
    }

    /// 涨跌幅。
    func lazyChangeLabel() -> UILabel {
        UILabel().then {
            $0.text = "--"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }.make(self) {
            $0.leading.equalTo(priceLabel.snp.trailing).offset(10.rpx)
            $0.bottom.equalTo(priceLabel).offset(-4.rpx)
        }
    }

    /// 24h 高/低/量。
    func lazyStatsLabel() -> UILabel {
        UILabel().then {
            $0.textColor = VLTradeAppearance.textSecondary
            $0.font = .systemFont(ofSize: 11, weight: .regular)
            $0.numberOfLines = 1
        }.make(self) {
            $0.top.equalTo(priceLabel.snp.bottom).offset(6.rpx)
            $0.leading.equalTo(symbolLabel)
            $0.trailing.lessThanOrEqualToSuperview().offset(-VLTradeLayout.horizontalInset)
            $0.bottom.equalToSuperview().offset(-8.rpx)
        }
    }
}
