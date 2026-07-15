//
//  VLTradeCandleMapperTests.swift
//  K 线 mapper 单元测试
//

import XCTest
@testable import mySwiftCoin

final class VLTradeCandleMapperTests: XCTestCase {

    /// 空数组应安全返回空 quotes。
    func testToStockeeQuotes_emptyIsSafe() {
        XCTAssertTrue(VLTradeMapper.toStockeeQuotes([]).isEmpty)
    }

    /// 单根蜡烛字段应完整映射。
    func testToStockeeQuotes_mapsOHLCV() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let candle = VLTradeCandleModel(
            date: date, open: 100, high: 110, low: 90, close: 105, volume: 12.5
        )
        let quotes = VLTradeMapper.toStockeeQuotes([candle])
        XCTAssertEqual(quotes.count, 1)
        XCTAssertEqual(quotes[0].date, date)
        XCTAssertEqual(quotes[0].open, 100)
        XCTAssertEqual(quotes[0].high, 110)
        XCTAssertEqual(quotes[0].low, 90)
        XCTAssertEqual(quotes[0].close, 105)
        XCTAssertEqual(quotes[0].volume, 12.5)
    }

    /// 多根蜡烛应保持输入顺序。
    func testToStockeeQuotes_preservesOrder() {
        let c1 = VLTradeCandleModel(date: Date(timeIntervalSince1970: 1), open: 1, high: 2, low: 1, close: 1.5, volume: 1)
        let c2 = VLTradeCandleModel(date: Date(timeIntervalSince1970: 2), open: 2, high: 3, low: 2, close: 2.5, volume: 2)
        let quotes = VLTradeMapper.toStockeeQuotes([c1, c2])
        XCTAssertEqual(quotes.count, 2)
        XCTAssertEqual(quotes[0].close, 1.5)
        XCTAssertEqual(quotes[1].close, 2.5)
    }

    /// Stockee Quote 适配应与 mapper 字段一致。
    func testToChartCandles_matchesMapperFields() {
        let candle = VLTradeCandleModel(
            date: Date(timeIntervalSince1970: 42),
            open: 10, high: 12, low: 9, close: 11, volume: 3
        )
        let chart = VLTradeKLineView.toChartCandles([candle])
        XCTAssertEqual(chart.count, 1)
        XCTAssertEqual(chart[0].open, 10)
        XCTAssertEqual(chart[0].close, 11)
        XCTAssertEqual(chart[0].volume, 3)
    }
}
