//
 //  VLTradeOKXMapperTests.swift
 //  OKX 行情 JSON 映射测试
 //

import XCTest
@testable import mySwiftCoin

final class VLTradeOKXMapperTests: XCTestCase {

    /// instId 现货 / 永续正确。
    func testInstId_spotAndSwap() {
        XCTAssertEqual(VLTradeOKXMapper.spotInstId(), "BTC-USDT")
        XCTAssertEqual(VLTradeOKXMapper.swapInstId(), "BTC-USDT-SWAP")
        XCTAssertEqual(VLTradeOKXMapper.instId(for: .spot, symbol: "ETH/USDT"), "ETH-USDT")
        XCTAssertEqual(VLTradeOKXMapper.instId(for: .futures, symbol: "ETH/USDT"), "ETH-USDT-SWAP")
    }

    /// displaySymbol 去掉 SWAP 后缀。
    func testDisplaySymbol() {
        XCTAssertEqual(VLTradeOKXMapper.displaySymbol(instId: "BTC-USDT"), "BTC/USDT")
        XCTAssertEqual(VLTradeOKXMapper.displaySymbol(instId: "BTC-USDT-SWAP"), "BTC/USDT")
    }

    /// ticker 解析涨跌与价格。
    func testTickerMapping() {
        let dict: [String: Any] = [
            "instId": "BTC-USDT",
            "last": "68000",
            "open24h": "66000",
            "high24h": "69000",
            "low24h": "65000",
            "volCcy24h": "1234567890"
        ]
        let ticker = VLTradeOKXMapper.ticker(from: dict)
        XCTAssertEqual(ticker?.symbol, "BTC/USDT")
        XCTAssertTrue(ticker?.isUp ?? false)
        XCTAssertTrue(ticker?.changePercent.contains("+") ?? false)
        XCTAssertFalse(ticker?.lastPrice.isEmpty ?? true)
        XCTAssertTrue(ticker?.volume24h.contains("亿") ?? false)
    }

    /// books5 解析档位与 depth。
    func testOrderBookMapping() {
        let dict: [String: Any] = [
            "asks": [
                ["111.06", "10", "0", "2"],
                ["111.07", "20", "0", "2"]
            ],
            "bids": [
                ["111.05", "15", "0", "2"],
                ["111.04", "5", "0", "2"]
            ]
        ]
        let book = VLTradeOKXMapper.orderBook(from: dict)
        XCTAssertEqual(book?.asks.count, 2)
        XCTAssertEqual(book?.bids.count, 2)
        XCTAssertEqual(book?.asks.first?.price, "111.06")
        XCTAssertEqual(book?.bids.first?.price, "111.05")
        book?.asks.forEach {
            XCTAssertGreaterThanOrEqual($0.depthRatio, 0)
            XCTAssertLessThanOrEqual($0.depthRatio, 1)
        }
    }

    /// 空 ticker 应返回 nil。
    func testTickerMapping_emptyLast_returnsNil() {
        XCTAssertNil(VLTradeOKXMapper.ticker(from: ["instId": "BTC-USDT"]))
    }
}
