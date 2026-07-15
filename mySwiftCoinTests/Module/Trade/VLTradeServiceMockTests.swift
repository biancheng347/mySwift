//
//  VLTradeServiceMockTests.swift
//  交易 Service mock 单元测试
//

import XCTest
@testable import mySwiftCoin

final class VLTradeServiceMockTests: XCTestCase {

    private var sut: VLTradeService!

    override func setUp() {
        super.setUp()
        sut = VLTradeService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    /// mock ticker 应带非空最新价与涨跌。
    func testMockTicker_hasPriceAndChange() {
        let ticker = sut.mockTicker(symbol: "BTC/USDT")
        XCTAssertEqual(ticker.symbol, "BTC/USDT")
        XCTAssertFalse(ticker.lastPrice.isEmpty)
        XCTAssertFalse(ticker.changePercent.isEmpty)
        XCTAssertFalse(ticker.high24h.isEmpty)
        XCTAssertFalse(ticker.low24h.isEmpty)
        XCTAssertFalse(ticker.volume24h.isEmpty)
    }

    /// mock 蜡烛数量应足够支撑缩放（≥80）。
    func testMockCandles_hasEnoughBars() {
        let candles = sut.mockCandles(symbol: "BTC/USDT", timeframe: .m15)
        XCTAssertGreaterThanOrEqual(candles.count, 80)
        let last = candles.last!
        XCTAssertGreaterThan(last.high, last.low)
        XCTAssertGreaterThan(last.volume, 0)
    }

    /// 不同周期应产出相同根数但时间步长不同（相邻 date 间隔随周期变化）。
    func testMockCandles_intervalAffectsSpacing() {
        let m15 = sut.mockCandles(symbol: "BTC/USDT", timeframe: .m15)
        let h1 = sut.mockCandles(symbol: "BTC/USDT", timeframe: .h1)
        XCTAssertEqual(m15.count, h1.count)
        let m15Gap = m15[1].date.timeIntervalSince(m15[0].date)
        let h1Gap = h1[1].date.timeIntervalSince(h1[0].date)
        XCTAssertEqual(m15Gap, 15 * 60, accuracy: 1)
        XCTAssertEqual(h1Gap, 60 * 60, accuracy: 1)
    }

    /// mock 盘口买卖侧应非空且带 depth。
    func testMockOrderBook_hasBidsAsksWithDepth() {
        let book = sut.mockOrderBook(symbol: "BTC/USDT")
        XCTAssertEqual(book.bids.count, VLTradeLayout.orderBookLevels)
        XCTAssertEqual(book.asks.count, VLTradeLayout.orderBookLevels)
        book.bids.forEach { XCTAssertGreaterThan($0.depthRatio, 0) }
        book.asks.forEach { XCTAssertGreaterThan($0.depthRatio, 0) }
    }
}
