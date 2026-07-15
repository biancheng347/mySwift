import Foundation
import CoreGraphics
import Then

/// OKX 公共 WS / REST JSON → 领域模型。
enum VLTradeOKXMapper {

    /// 现货交易对 → OKX instId。
    static func spotInstId(symbol: String = "BTC/USDT") -> String {
        symbol.replacingOccurrences(of: "/", with: "-")
    }

    /// 永续合约 instId。
    static func swapInstId(symbol: String = "BTC/USDT") -> String {
        "\(spotInstId(symbol: symbol))-SWAP"
    }

    /// 按分类解析订阅合约 ID。
    static func instId(for category: VLTradeCategory, symbol: String = "BTC/USDT") -> String {
        category == .futures ? swapInstId(symbol: symbol) : spotInstId(symbol: symbol)
    }

    /// 展示用交易对（BTC-USDT / BTC-USDT-SWAP → BTC/USDT）。
    static func displaySymbol(instId: String) -> String {
        let base = instId.replacingOccurrences(of: "-SWAP", with: "")
        let parts = base.split(separator: "-")
        guard parts.count >= 2 else { return instId }
        return "\(parts[0])/\(parts[1])"
    }

    /// 解析 tickers 推送 data[0]。
    static func ticker(from dict: [String: Any]) -> VLTradeTickerModel? {
        guard let last = dict["last"] as? String, !last.isEmpty else { return nil }
        let open = dict["open24h"] as? String ?? last
        let lastValue = Double(last) ?? 0
        let openValue = Double(open) ?? lastValue
        let change = openValue > 0 ? (lastValue - openValue) / openValue * 100 : 0
        let instId = dict["instId"] as? String ?? "BTC-USDT"
        return VLTradeTickerModel().then {
            $0.instId = instId
            $0.symbol = displaySymbol(instId: instId)
            $0.lastPrice = formatPrice(last)
            $0.changePercent = String(format: "%@%.2f%%", change >= 0 ? "+" : "", change)
            $0.isUp = change >= 0
            $0.high24h = formatPrice(dict["high24h"] as? String ?? "--")
            $0.low24h = formatPrice(dict["low24h"] as? String ?? "--")
            $0.volume24h = formatVolume(dict["volCcy24h"] as? String ?? dict["vol24h"] as? String)
        }
    }

    /// 解析 books5 data[0]。
    static func orderBook(from dict: [String: Any]) -> VLTradeOrderBookModel? {
        let asksRaw = dict["asks"] as? [[Any]] ?? []
        let bidsRaw = dict["bids"] as? [[Any]] ?? []
        let askLevels = levels(from: asksRaw)
        let bidLevels = levels(from: bidsRaw)
        guard !askLevels.isEmpty || !bidLevels.isEmpty else { return nil }
        let asks = VLTradeMapper.withDepthRatios(
            prices: askLevels.map(\.0),
            amounts: askLevels.map(\.1)
        )
        let bids = VLTradeMapper.withDepthRatios(
            prices: bidLevels.map(\.0),
            amounts: bidLevels.map(\.1)
        )
        let sorted = VLTradeMapper.sortOrderBook(bids: bids, asks: asks)
        return VLTradeOrderBookModel().then {
            $0.asks = Array(sorted.asks.prefix(VLTradeLayout.orderBookLevels))
            $0.bids = Array(sorted.bids.prefix(VLTradeLayout.orderBookLevels))
        }
    }

    /// 解析 REST candles 行（OKX 新→旧），返回时间升序领域蜡烛。
    static func candles(from rows: [[String]]) -> [VLTradeCandleModel] {
        let parsed: [VLTradeCandleModel] = rows.compactMap { row in
            guard row.count >= 6,
                  let tsMs = Double(row[0]),
                  let open = CGFloat.fromOKX(row[1]),
                  let high = CGFloat.fromOKX(row[2]),
                  let low = CGFloat.fromOKX(row[3]),
                  let close = CGFloat.fromOKX(row[4]),
                  let volume = CGFloat.fromOKX(row[5]) else { return nil }
            return VLTradeCandleModel(
                date: Date(timeIntervalSince1970: tsMs / 1000),
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume
            )
        }
        return parsed.sorted { $0.date < $1.date }
    }

    /// 格式化价格（千分位，最多 1 位小数或原样）。
    static func formatPrice(_ raw: String) -> String {
        guard let value = Double(raw) else { return raw }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = value >= 100 ? 1 : 4
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? raw
    }

    /// 格式化 24h 成交量。
    static func formatVolume(_ raw: String?) -> String {
        guard let raw, let value = Double(raw) else { return "--" }
        if value >= 100_000_000 {
            return String(format: "%.2f亿", value / 100_000_000)
        }
        if value >= 10_000 {
            return String(format: "%.2f万", value / 10_000)
        }
        return formatPrice(raw)
    }
}

fileprivate extension VLTradeOKXMapper {

    /// [[price, size, ...]] → [(price, amount)]。
    static func levels(from rows: [[Any]]) -> [(String, String)] {
        rows.compactMap { row in
            guard row.count >= 2 else { return nil }
            let price = "\(row[0])"
            let amount = "\(row[1])"
            guard Double(price) != nil, Double(amount) != nil else { return nil }
            return (price, amount)
        }
    }
}

fileprivate extension CGFloat {
    /// 从 OKX 字符串价格解析。
    static func fromOKX(_ raw: String) -> CGFloat? {
        guard let value = Double(raw) else { return nil }
        return CGFloat(value)
    }
}
