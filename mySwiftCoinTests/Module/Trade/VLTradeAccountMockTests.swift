//
//  VLTradeAccountMockTests.swift
//  底部持仓/委托/资产 mock 测试
//

import XCTest
@testable import mySwiftCoin

final class VLTradeAccountMockTests: XCTestCase {

    private var sut: VLTradeService!

    override func setUp() {
        super.setUp()
        sut = VLTradeService(useLiveREST: false)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    /// 现货 Tab：委托 + 资产。
    func testSpotTabs() {
        XCTAssertEqual(VLTradeBottomTab.spotTabs, [.openOrders, .assets])
    }

    /// 合约 Tab：持仓 + 委托。
    func testFuturesTabs() {
        XCTAssertEqual(VLTradeBottomTab.futuresTabs, [.positions, .openOrders])
    }

    /// 合约盘口数量应为整数张，且仍截成 5 档。
    func testFuturesOrderBook_usesContracts() {
        let book = sut.mockFuturesOrderBook(symbol: "BTC/USDT")
        XCTAssertEqual(book.bids.count, VLTradeLayout.orderBookLevels)
        XCTAssertEqual(book.asks.count, VLTradeLayout.orderBookLevels)
        book.bids.forEach {
            XCTAssertNil($0.amount.firstIndex(of: "."), "合约张数应为整数: \($0.amount)")
            XCTAssertGreaterThan(Double($0.amount) ?? 0, 0)
        }
    }

    /// 现货账户含委托与资产。
    func testMockSpotAccount_hasOrdersAndAssets() {
        let snap = sut.mockSpotAccount(symbol: "BTC/USDT")
        XCTAssertEqual(snap.openOrders.count, 2)
        XCTAssertEqual(snap.assets.count, 2)
        XCTAssertTrue(snap.positions.isEmpty)
        XCTAssertFalse(snap.openOrders[0].isFutures)
    }

    /// 合约账户含持仓与委托。
    func testMockFuturesAccount_hasPositionsAndOrders() {
        let snap = sut.mockFuturesAccount(symbol: "ETH/USDT")
        XCTAssertEqual(snap.positions.count, 2)
        XCTAssertEqual(snap.openOrders.count, 2)
        XCTAssertTrue(snap.assets.isEmpty)
        XCTAssertTrue(snap.positions[0].isLong)
        XCTAssertFalse(snap.positions[1].isLong)
        XCTAssertEqual(snap.positions[0].sizeUnit, "张")
        XCTAssertTrue(snap.openOrders[0].isFutures)
    }
}
