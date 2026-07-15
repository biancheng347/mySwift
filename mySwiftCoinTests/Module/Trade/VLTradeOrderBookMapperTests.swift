//
//  VLTradeOrderBookMapperTests.swift
//  盘口 mapper 单元测试
//

import XCTest
@testable import mySwiftCoin

final class VLTradeOrderBookMapperTests: XCTestCase {

    /// depthRatio 应相对最大量归一化到 [0, 1]。
    func testWithDepthRatios_normalizesToMax() {
        let levels = VLTradeMapper.withDepthRatios(
            prices: ["100", "99", "98"],
            amounts: ["10", "5", "2.5"]
        )
        XCTAssertEqual(levels.count, 3)
        XCTAssertEqual(levels[0].depthRatio, 1.0, accuracy: 0.001)
        XCTAssertEqual(levels[1].depthRatio, 0.5, accuracy: 0.001)
        XCTAssertEqual(levels[2].depthRatio, 0.25, accuracy: 0.001)
        levels.forEach {
            XCTAssertGreaterThanOrEqual($0.depthRatio, 0)
            XCTAssertLessThanOrEqual($0.depthRatio, 1)
        }
    }

    /// 空输入应返回空档。
    func testWithDepthRatios_emptyIsSafe() {
        XCTAssertTrue(VLTradeMapper.withDepthRatios(prices: [], amounts: []).isEmpty)
    }

    /// 全零量时 depth 应为 0。
    func testWithDepthRatios_allZeroAmounts() {
        let levels = VLTradeMapper.withDepthRatios(prices: ["1", "2"], amounts: ["0", "0"])
        XCTAssertEqual(levels.count, 2)
        XCTAssertEqual(levels[0].depthRatio, 0)
        XCTAssertEqual(levels[1].depthRatio, 0)
    }

    /// asks 升序、bids 降序贴近中间价。
    func testSortOrderBook_asksAscBidsDesc() {
        let bids = [
            VLTradeOrderBookLevelModel(price: "100", amount: "1", depthRatio: 1),
            VLTradeOrderBookLevelModel(price: "102", amount: "1", depthRatio: 1),
            VLTradeOrderBookLevelModel(price: "101", amount: "1", depthRatio: 1),
        ]
        let asks = [
            VLTradeOrderBookLevelModel(price: "105", amount: "1", depthRatio: 1),
            VLTradeOrderBookLevelModel(price: "103", amount: "1", depthRatio: 1),
            VLTradeOrderBookLevelModel(price: "104", amount: "1", depthRatio: 1),
        ]
        let sorted = VLTradeMapper.sortOrderBook(bids: bids, asks: asks)
        XCTAssertEqual(sorted.bids.map(\.price), ["102", "101", "100"])
        XCTAssertEqual(sorted.asks.map(\.price), ["103", "104", "105"])
    }
}
