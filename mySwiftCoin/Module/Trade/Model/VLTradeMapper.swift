import Foundation
import CoreGraphics

/// 将领域蜡烛转为 Stockee `Quote` 适配结构（不依赖 Stockee 的测试映射）。
struct VLTradeStockeeQuote {
    var date: Date
    var open: CGFloat
    var high: CGFloat
    var low: CGFloat
    var close: CGFloat
    var volume: CGFloat
}

/// K 线与盘口纯函数映射。
enum VLTradeMapper {

    /// 领域蜡烛 → Stockee 可消费字段；空输入安全。
    static func toStockeeQuotes(_ candles: [VLTradeCandleModel]) -> [VLTradeStockeeQuote] {
        candles.map {
            VLTradeStockeeQuote(
                date: $0.date,
                open: $0.open,
                high: $0.high,
                low: $0.low,
                close: $0.close,
                volume: $0.volume
            )
        }
    }

    /// 为 bids/asks 计算 depthRatio（相对本侧最大量），范围 [0, 1]。
    static func withDepthRatios(
        prices: [String],
        amounts: [String]
    ) -> [VLTradeOrderBookLevelModel] {
        let count = min(prices.count, amounts.count)
        guard count > 0 else { return [] }
        let values = (0..<count).map { CGFloat(Double(amounts[$0]) ?? 0) }
        let maxAmount = values.max() ?? 0
        return (0..<count).map { index in
            let ratio: CGFloat = maxAmount > 0 ? values[index] / maxAmount : 0
            return VLTradeOrderBookLevelModel(
                price: prices[index],
                amount: amounts[index],
                depthRatio: ratio
            )
        }
    }

    /// asks 按价格升序（低价在上贴近中间价），bids 按价格降序。
    static func sortOrderBook(
        bids: [VLTradeOrderBookLevelModel],
        asks: [VLTradeOrderBookLevelModel]
    ) -> (bids: [VLTradeOrderBookLevelModel], asks: [VLTradeOrderBookLevelModel]) {
        let sortedBids = bids.sorted {
            (Double($0.price) ?? 0) > (Double($1.price) ?? 0)
        }
        let sortedAsks = asks.sorted {
            (Double($0.price) ?? 0) < (Double($1.price) ?? 0)
        }
        return (sortedBids, sortedAsks)
    }
}
