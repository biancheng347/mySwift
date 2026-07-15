//
//  VLHomeExchangeMapperTests.swift
//  首页交易所 Mapper 单元测试
//

import XCTest
@testable import mySwiftCoin

final class VLHomeExchangeMapperTests: XCTestCase {

    private var sourceItems: [VLHomeExchangeListItem]!

    override func setUp() {
        super.setUp()
        sourceItems = VLHomeExchangeService().mockList()
    }

    override func tearDown() {
        sourceItems = nil
        super.tearDown()
    }

    /// Mapper 应产出 6 个 ItemTypeProtocol 行。
    func testToItems_producesSixItems() {
        let mapped = toItems(sourceItems)
        XCTAssertEqual(mapped.count, 6)
    }

    /// 固定高度 Cell 应使用预期的 reuse 标识符。
    func testToItems_cellTypeStrings() {
        let mapped = toItems(sourceItems)
        XCTAssertEqual(mapped[0].cellTypeStr, VLHomeSearchCell.str)
        XCTAssertEqual(mapped[1].cellTypeStr, VLHomeAssetsCell.str)
        XCTAssertEqual(mapped[2].cellTypeStr, VLHomeBannerCell.str)
        XCTAssertEqual(mapped[3].cellTypeStr, VLHomeMarketListCell.str)
        XCTAssertEqual(mapped[4].cellTypeStr, VLHomeMarketOverviewCell.str)
        XCTAssertEqual(mapped[5].cellTypeStr, VLHomeAnnouncementCell.str)
    }

    /// 固定分区高度应与 VLHomeCellConfig 一致。
    func testToItems_fixedHeights() {
        let mapped = toItems(sourceItems)
        XCTAssertEqual(mapped[0].cellSizeHeight, VLHomeCellConfig.search.conf.height, accuracy: 0.5)
        XCTAssertEqual(mapped[1].cellSizeHeight, VLHomeCellConfig.assets.conf.height, accuracy: 0.5)
        XCTAssertEqual(mapped[2].cellSizeHeight, VLHomeCellConfig.banner.conf.height, accuracy: 0.5)
        XCTAssertEqual(mapped[3].cellSizeHeight, VLHomeCellConfig.marketList.conf.height, accuracy: 0.5)
    }

    /// 动态分区高度应为正数。
    func testToItems_dynamicHeightsArePositive() {
        let mapped = toItems(sourceItems)
        XCTAssertGreaterThan(mapped[4].cellSizeHeight, 0)
        XCTAssertGreaterThan(mapped[5].cellSizeHeight, 0)
        XCTAssertEqual(mapped[0].cellSizeWidth, AppWidth, accuracy: 0.5)
    }
}
