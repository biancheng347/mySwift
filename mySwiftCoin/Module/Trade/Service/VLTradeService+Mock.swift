import Foundation
import CoreGraphics
import Then

/// 交易页 Phase 1 mock 数据（对齐 OKX 视觉量级）。
extension VLTradeService {

    /// 返回静态 ticker mock。
    func mockTicker(symbol: String) -> VLTradeTickerModel {
        let isETH = symbol.contains("ETH")
        return VLTradeTickerModel().then {
            $0.symbol = symbol
            $0.lastPrice = isETH ? "3,245.6" : "67,890.1"
            $0.changePercent = isETH ? "+1.82%" : "+2.45%"
            $0.isUp = true
            $0.high24h = isETH ? "3,310.2" : "68,420.0"
            $0.low24h = isETH ? "3,180.5" : "65,810.5"
            $0.volume24h = isETH ? "18.42亿" : "56.83亿"
        }
    }

    /// 生成 ≥80 根伪随机游走蜡烛，周期决定时间步长。
    func mockCandles(symbol: String, timeframe: VLTradeTimeframe) -> [VLTradeCandleModel] {
        let count = 120
        let step = timeframeStepSeconds(timeframe)
        let end = Date()
        var price: CGFloat = symbol.contains("ETH") ? 3_200 : 67_000
        var candles: [VLTradeCandleModel] = []
        candles.reserveCapacity(count)
        for index in 0..<count {
            let date = end.addingTimeInterval(-Double(count - 1 - index) * step)
            let scale: CGFloat = symbol.contains("ETH") ? 0.05 : 1
            let drift = CGFloat((sin(Double(index) * 0.17) + cos(Double(index) * 0.07)) * 80) * scale
            let open = price
            let close = max(1, open + drift + CGFloat((index % 7) - 3) * 12 * scale)
            let high = max(open, close) + CGFloat(abs(index % 9)) * 8 * scale
            let low = min(open, close) - CGFloat(abs(index % 5)) * 6 * scale
            let volume = 80 + CGFloat((index * 13) % 40) + abs(drift) * 0.15
            candles.append(VLTradeCandleModel(
                date: date,
                open: open,
                high: high,
                low: max(1, low),
                close: close,
                volume: volume
            ))
            price = close
        }
        return candles
    }

    /// 现货买卖盘 mock（币数量）。
    func mockOrderBook(symbol: String) -> VLTradeOrderBookModel {
        makeOrderBook(
            mid: symbol.contains("ETH") ? 3_245.6 : 67_890.1,
            tick: symbol.contains("ETH") ? 0.1 : 2.5,
            levels: VLTradeLayout.orderBookLevels,
            amountBase: 0.8,
            amountStep: 0.35,
            decimals: symbol.contains("ETH") ? 2 : 1
        )
    }

    /// 合约盘口 mock：张数、更密档位供 books5 截取，金额更丰富。
    func mockFuturesOrderBook(symbol: String) -> VLTradeOrderBookModel {
        makeOrderBook(
            mid: symbol.contains("ETH") ? 3_245.6 : 67_890.1,
            tick: symbol.contains("ETH") ? 0.05 : 0.5,
            levels: VLTradeLayout.futuresOrderBookMockLevels,
            amountBase: 12,
            amountStep: 8.5,
            decimals: symbol.contains("ETH") ? 2 : 1,
            amountDecimals: 0
        )
    }

    /// 现货底部：当前委托 + 资产。
    func mockSpotAccount(symbol: String) -> VLTradeAccountSnapshotModel {
        let base = String(symbol.split(separator: "/").first ?? "BTC")
        return VLTradeAccountSnapshotModel().then {
            $0.openOrders = [
                VLTradeOpenOrderModel().then {
                    $0.symbol = symbol
                    $0.side = .buy
                    $0.isFutures = false
                    $0.orderType = "限价"
                    $0.price = base == "ETH" ? "3,180.0" : "66,500.0"
                    $0.amount = base == "ETH" ? "1.2000" : "0.0500"
                    $0.filled = "0.0000"
                    $0.timeText = "14:32:08"
                },
                VLTradeOpenOrderModel().then {
                    $0.symbol = symbol
                    $0.side = .sell
                    $0.isFutures = false
                    $0.orderType = "限价"
                    $0.price = base == "ETH" ? "3,360.0" : "69,200.0"
                    $0.amount = base == "ETH" ? "0.5000" : "0.0200"
                    $0.filled = "0.0100"
                    $0.timeText = "13:05:41"
                }
            ]
            $0.assets = [
                VLTradeAssetModel().then {
                    $0.coin = "USDT"
                    $0.available = "12,580.25"
                    $0.frozen = "320.00"
                    $0.equityUSDT = "12,900.25"
                },
                VLTradeAssetModel().then {
                    $0.coin = base
                    $0.available = base == "ETH" ? "2.4500" : "0.1862"
                    $0.frozen = base == "ETH" ? "0.1200" : "0.0200"
                    $0.equityUSDT = base == "ETH" ? "8,352.10" : "14,021.34"
                }
            ]
        }
    }

    /// 合约底部：当前持仓 + 当前委托。
    func mockFuturesAccount(symbol: String) -> VLTradeAccountSnapshotModel {
        let base = String(symbol.split(separator: "/").first ?? "BTC")
        return VLTradeAccountSnapshotModel().then {
            $0.positions = [
                VLTradePositionModel().then {
                    $0.symbol = symbol
                    $0.isLong = true
                    $0.isCrossMargin = true
                    $0.leverage = "10x"
                    $0.size = base == "ETH" ? "25" : "12"
                    $0.sizeUnit = "张"
                    $0.avgPrice = base == "ETH" ? "3,120.4" : "66,850.0"
                    $0.markPrice = base == "ETH" ? "3,245.6" : "67,890.1"
                    $0.liqPrice = base == "ETH" ? "2,680.0" : "58,420.0"
                    $0.margin = base == "ETH" ? "812.0 USDT" : "814.7 USDT"
                    $0.pnl = base == "ETH" ? "+312.80" : "+1,248.12"
                    $0.pnlRatio = base == "ETH" ? "+38.52%" : "+15.32%"
                    $0.isProfit = true
                },
                VLTradePositionModel().then {
                    $0.symbol = symbol
                    $0.isLong = false
                    $0.isCrossMargin = false
                    $0.leverage = "5x"
                    $0.size = base == "ETH" ? "8" : "3"
                    $0.sizeUnit = "张"
                    $0.avgPrice = base == "ETH" ? "3,310.0" : "68,500.0"
                    $0.markPrice = base == "ETH" ? "3,245.6" : "67,890.1"
                    $0.liqPrice = base == "ETH" ? "3,620.0" : "74,200.0"
                    $0.margin = base == "ETH" ? "529.6 USDT" : "410.3 USDT"
                    $0.pnl = base == "ETH" ? "+51.52" : "+183.00"
                    $0.pnlRatio = base == "ETH" ? "+9.73%" : "+4.46%"
                    $0.isProfit = true
                }
            ]
            $0.openOrders = [
                VLTradeOpenOrderModel().then {
                    $0.symbol = symbol
                    $0.side = .buy
                    $0.isFutures = true
                    $0.orderType = "限价"
                    $0.price = base == "ETH" ? "3,100.0" : "66,200.0"
                    $0.amount = base == "ETH" ? "10" : "5"
                    $0.filled = "0"
                    $0.timeText = "15:01:22"
                },
                VLTradeOpenOrderModel().then {
                    $0.symbol = symbol
                    $0.side = .sell
                    $0.isFutures = true
                    $0.orderType = "限价"
                    $0.price = base == "ETH" ? "3,420.0" : "69,800.0"
                    $0.amount = base == "ETH" ? "6" : "2"
                    $0.filled = "1"
                    $0.timeText = "12:48:03"
                }
            ]
        }
    }

    /// 组装买卖盘。
    private func makeOrderBook(
        mid: Double,
        tick: Double,
        levels: Int,
        amountBase: Double,
        amountStep: Double,
        decimals: Int,
        amountDecimals: Int = 4
    ) -> VLTradeOrderBookModel {
        var bidPrices: [String] = []
        var bidAmounts: [String] = []
        var askPrices: [String] = []
        var askAmounts: [String] = []
        let priceFmt = "%.\(decimals)f"
        let amtFmt = "%.\(amountDecimals)f"
        for i in 0..<levels {
            let bid = mid - Double(i + 1) * tick
            let ask = mid + Double(i + 1) * tick
            bidPrices.append(String(format: priceFmt, bid))
            askPrices.append(String(format: priceFmt, ask))
            bidAmounts.append(String(format: amtFmt, amountBase + Double(levels - i) * amountStep))
            askAmounts.append(String(format: amtFmt, amountBase * 0.8 + Double(levels - i) * amountStep * 0.9))
        }
        let bids = VLTradeMapper.withDepthRatios(prices: bidPrices, amounts: bidAmounts)
        let asks = VLTradeMapper.withDepthRatios(prices: askPrices, amounts: askAmounts)
        let sorted = VLTradeMapper.sortOrderBook(bids: bids, asks: asks)
        return VLTradeOrderBookModel().then {
            $0.bids = Array(sorted.bids.prefix(VLTradeLayout.orderBookLevels))
            $0.asks = Array(sorted.asks.prefix(VLTradeLayout.orderBookLevels))
        }
    }

    /// 周期对应秒数。
    private func timeframeStepSeconds(_ timeframe: VLTradeTimeframe) -> TimeInterval {
        switch timeframe {
        case .line: return 60
        case .m15, .more: return 15 * 60
        case .h1: return 60 * 60
        case .h4: return 4 * 60 * 60
        case .d1: return 24 * 60 * 60
        }
    }
}
