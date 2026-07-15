import Foundation
import CoreGraphics
import Then

/// 交易对常量（OKX 现货 BTC / ETH）。
enum VLTradePair {
    static let btcUSDT = "BTC/USDT"
    static let ethUSDT = "ETH/USDT"
    /// 本页可切换交易对。
    static let tradableSymbols = [btcUSDT, ethUSDT]
}

/// 交易顶部分类（对齐 OKX：现货 / 闪兑 / 合约 / 策略）。
enum VLTradeCategory: Int, CaseIterable {
    case spot = 0
    case convert = 1
    case futures = 2
    case strategy = 3

    /// Tab 文案。
    var title: String {
        switch self {
        case .spot: return "现货"
        case .convert: return "闪兑"
        case .futures: return "合约"
        case .strategy: return "策略"
        }
    }

    /// 是否走盘口+表单行情面板。
    var isMarketPanel: Bool {
        self == .spot || self == .futures
    }
}

/// K 线周期选项（对齐 OKX 常用 chips）。
enum VLTradeTimeframe: String, CaseIterable {
    case line = "分时"
    case m15 = "15分"
    case h1 = "1时"
    case h4 = "4时"
    case d1 = "1日"
    case more = "更多"

    /// 默认选中周期。
    static let `default`: VLTradeTimeframe = .m15

    /// 是否为分时图（Stockee `TimeShareChart`）。
    var isTimeShare: Bool { self == .line }

    /// mock / 本地 interval key。
    var intervalKey: String {
        switch self {
        case .line: return "1m"
        case .m15: return "15m"
        case .h1: return "1h"
        case .h4: return "4h"
        case .d1: return "1d"
        case .more: return "15m"
        }
    }

    /// OKX REST `bar`（1H/4H/1D 为大写）。
    var okxBar: String {
        switch self {
        case .line: return "1m"
        case .m15, .more: return "15m"
        case .h1: return "1H"
        case .h4: return "4H"
        case .d1: return "1D"
        }
    }
}

/// 买卖方向。
enum VLTradeSide: Int {
    case buy = 0
    case sell = 1
}

/// 行情 ticker 摘要。
final class VLTradeTickerModel: Then {
    var symbol: String = "BTC/USDT"
    var instId: String = "BTC-USDT"
    var lastPrice: String = ""
    var changePercent: String = ""
    var isUp: Bool = true
    var high24h: String = ""
    var low24h: String = ""
    var volume24h: String = ""

    init() {}
}

/// 单根 OHLCV K 线（领域模型；Chart 适配另见 mapper）。
final class VLTradeCandleModel: Then {
    var date: Date = Date()
    var open: CGFloat = 0
    var high: CGFloat = 0
    var low: CGFloat = 0
    var close: CGFloat = 0
    var volume: CGFloat = 0

    init() {}

    /// 便捷初始化，供 mock 与 mapper 测试使用。
    convenience init(
        date: Date,
        open: CGFloat,
        high: CGFloat,
        low: CGFloat,
        close: CGFloat,
        volume: CGFloat
    ) {
        self.init()
        self.date = date
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
    }
}

/// 盘口单档。
final class VLTradeOrderBookLevelModel: Then {
    var price: String = ""
    var amount: String = ""
    var depthRatio: CGFloat = 0

    init() {}

    convenience init(price: String, amount: String, depthRatio: CGFloat) {
        self.init()
        self.price = price
        self.amount = amount
        self.depthRatio = depthRatio
    }
}

/// 买卖盘快照。
final class VLTradeOrderBookModel: Then {
    var bids: [VLTradeOrderBookLevelModel] = []
    var asks: [VLTradeOrderBookLevelModel] = []

    init() {}
}

/// 下单表单 UI 状态。
final class VLTradeOrderFormModel: Then {
    var side: VLTradeSide = .buy
    var price: String = ""
    var amount: String = ""
    var leverage: String = "10x"
    var isCrossMargin: Bool = true

    init() {}
}
