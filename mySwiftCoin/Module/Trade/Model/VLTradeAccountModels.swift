import Foundation
import Then

/// 现货/合约底部 Tab（对齐 OKX App）。
enum VLTradeBottomTab: Int, CaseIterable {
    case positions = 0
    case openOrders = 1
    case assets = 2

    /// 展示文案。
    var title: String {
        switch self {
        case .positions: return "当前持仓"
        case .openOrders: return "当前委托"
        case .assets: return "资产"
        }
    }

    /// 现货默认 Tab 集合。
    static let spotTabs: [VLTradeBottomTab] = [.openOrders, .assets]
    /// 合约默认 Tab 集合。
    static let futuresTabs: [VLTradeBottomTab] = [.positions, .openOrders]
}

/// 合约持仓 mock（对齐 OKX 仓位卡）。
final class VLTradePositionModel: Then {
    var symbol: String = "BTC/USDT"
    var isLong: Bool = true
    var isCrossMargin: Bool = true
    var leverage: String = "10x"
    var size: String = "0.1"
    var sizeUnit: String = "张"
    var avgPrice: String = "67,200.5"
    var markPrice: String = "67,890.1"
    var liqPrice: String = "58,420.0"
    var margin: String = "678.9 USDT"
    var pnl: String = "+68.96"
    var pnlRatio: String = "+10.15%"
    var isProfit: Bool = true

    init() {}
}

/// 当前委托 mock。
final class VLTradeOpenOrderModel: Then {
    var symbol: String = "BTC/USDT"
    var side: VLTradeSide = .buy
    var isFutures: Bool = false
    var orderType: String = "限价"
    var price: String = "66,500.0"
    var amount: String = "0.0500"
    var filled: String = "0.0000"
    var timeText: String = "14:32:08"

    init() {}

    /// 侧向中文（现货买/卖，合约开多/开空）。
    var sideTitle: String {
        if isFutures {
            return side == .buy ? "开多" : "开空"
        }
        return side == .buy ? "买入" : "卖出"
    }
}

/// 现货资产 mock。
final class VLTradeAssetModel: Then {
    var coin: String = "USDT"
    var available: String = "12,580.25"
    var frozen: String = "320.00"
    var equityUSDT: String = "12,900.25"

    init() {}
}

/// 底部账户区快照。
final class VLTradeAccountSnapshotModel: Then {
    var positions: [VLTradePositionModel] = []
    var openOrders: [VLTradeOpenOrderModel] = []
    var assets: [VLTradeAssetModel] = []

    init() {}
}
