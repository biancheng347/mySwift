//
//  VLTradeOKXCandleMapperTests.swift
//  OKX K 线 REST 映射单元测试
//

import XCTest
@testable import mySwiftCoin

final class VLTradeOKXCandleMapperTests: XCTestCase {

    /// OKX bar 参数应对齐文档（1H/4H/1D 大写）。
    func testTimeframe_okxBar() {
        XCTAssertEqual(VLTradeTimeframe.line.okxBar, "1m")
        XCTAssertEqual(VLTradeTimeframe.m15.okxBar, "15m")
        XCTAssertEqual(VLTradeTimeframe.h1.okxBar, "1H")
        XCTAssertEqual(VLTradeTimeframe.h4.okxBar, "4H")
        XCTAssertEqual(VLTradeTimeframe.d1.okxBar, "1D")
    }

    /// candles 行应按时间升序返回（OKX 原始为新→旧）。
    func testCandles_fromRows_sortedAscending() {
        let rows: [[String]] = [
            ["1700001200000", "102", "103", "101", "102.5", "1.5", "0", "0", "1"],
            ["1700000000000", "100", "101", "99", "100.5", "2.0", "0", "0", "1"]
        ]
        let candles = VLTradeOKXMapper.candles(from: rows)
        XCTAssertEqual(candles.count, 2)
        XCTAssertEqual(candles[0].open, 100)
        XCTAssertEqual(candles[1].open, 102)
        XCTAssertLessThan(candles[0].date, candles[1].date)
    }

    /// 非法行应跳过，不强行崩溃。
    func testCandles_skipsInvalidRows() {
        let rows: [[String]] = [
            ["bad"],
            ["1700000000000", "100", "101", "99", "100.5", "2.0"]
        ]
        let candles = VLTradeOKXMapper.candles(from: rows)
        XCTAssertEqual(candles.count, 1)
    }

    /// 可交易对应含 BTC / ETH。
    func testTradableSymbols_includeBTCandETH() {
        XCTAssertEqual(VLTradePair.tradableSymbols, ["BTC/USDT", "ETH/USDT"])
    }
}
