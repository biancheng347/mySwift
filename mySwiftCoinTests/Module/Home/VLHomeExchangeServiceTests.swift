//
//  VLHomeExchangeServiceTests.swift
//  首页交易所 Service 单元测试
//

import XCTest
@testable import mySwiftCoin

final class VLHomeExchangeServiceTests: XCTestCase {

    private var sut: VLHomeExchangeService!

    override func setUp() {
        super.setUp()
        sut = VLHomeExchangeService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    /// mock 列表应返回六个分区，顺序与 Flutter 一致。
    func testMockList_returnsSixItemsInOrder() {
        let items = sut.mockList()
        XCTAssertEqual(items.count, 6)
        XCTAssertEqual(items.map(\.kind), [
            .search, .assets, .banner, .marketList, .marketOverview, .announcement,
        ])
    }

    /// 搜索分区应携带 Flutter mock 的三条提示芯片。
    func testMockList_searchHintsMatchFlutter() {
        let items = sut.mockList()
        guard case .search(let model) = items[0] else {
            return XCTFail("Expected search item first")
        }
        XCTAssertEqual(model.hints.count, 3)
        XCTAssertEqual(model.hints[0].text, "BTC/USDT")
        XCTAssertEqual(model.hints[1].text, "ETH 热门")
        XCTAssertEqual(model.hints[2].text, "搜索币种/合约")
    }

    /// 资产分区应包含四个币种选项。
    func testMockList_assetsHasFourCurrencies() {
        let items = sut.mockList()
        guard case .assets(let model) = items[1] else {
            return XCTFail("Expected assets item second")
        }
        XCTAssertEqual(model.currencies.count, 4)
        XCTAssertEqual(model.currencies[0].symbol, "USDT")
    }
}
