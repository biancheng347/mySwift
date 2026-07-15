//
//  VLHomeLayoutTests.swift
//  首页 OKX 风格布局令牌单元测试
//

import XCTest
@testable import mySwiftCoin

final class VLHomeLayoutTests: XCTestCase {

    /// 水平边距应对齐 OKX 常规 16pt。
    func testHorizontalInset() {
        XCTAssertEqual(VLHomeLayout.horizontalInset, 16.rpx, accuracy: 0.5)
    }

    /// 涨跌幅徽章为固定宽高，便于列对齐。
    func testChangeBadgeSize() {
        XCTAssertEqual(VLHomeLayout.changeBadgeWidth, 72.rpx, accuracy: 0.5)
        XCTAssertEqual(VLHomeLayout.changeBadgeHeight, 28.rpx, accuracy: 0.5)
    }

    /// 币种行与列头高度固定。
    func testMarketRowAndHeaderHeights() {
        XCTAssertEqual(VLHomeLayout.coinRowHeight, 56.rpx, accuracy: 0.5)
        XCTAssertEqual(VLHomeLayout.columnHeaderHeight, 28.rpx, accuracy: 0.5)
    }

    /// 列头文案为 OKX 常规三列。
    func testColumnHeaderTitles() {
        XCTAssertEqual(VLHomeLayout.columnNameTitle, "名称")
        XCTAssertEqual(VLHomeLayout.columnPriceTitle, "最新价")
        XCTAssertEqual(VLHomeLayout.columnChangeTitle, "涨跌幅")
    }

    /// 行情列表高度应包含 Tab + 列头 + 最多 5 行 + 查看更多。
    func testMarketListCellHeightIncludesColumnHeader() {
        let height = VLHomeCellConfig.marketList.conf.height
        let expectedMin = VLHomeLayout.marketListBaseHeight
        XCTAssertGreaterThanOrEqual(height, expectedMin - 0.5)
        XCTAssertEqual(height, expectedMin, accuracy: 0.5)
    }

    /// 资产区高度应容纳「预估总资产」标题层级。
    func testAssetsCellHeight() {
        XCTAssertEqual(
            VLHomeCellConfig.assets.conf.height,
            VLHomeLayout.assetsCellHeight,
            accuracy: 0.5
        )
    }

    /// 行情概况按三列一行计算高度（3 卡 = 1 行）。
    func testMarketOverviewThreePerRowHeight() {
        let height = VLHomeCellConfig.marketOverview(cardCount: 3, hasEvent: true).conf.height
        let expected = 36.rpx + 72.rpx + 44.rpx + 8.rpx
        XCTAssertEqual(height, expected, accuracy: 0.5)
    }

    /// 公告高度公式：标题区 + 条目行 + 底边距。
    func testAnnouncementCellHeight() {
        let height = VLHomeCellConfig.announcement(entryCount: 3).conf.height
        let expected = 30.rpx + 3 * 64.rpx + 8.rpx
        XCTAssertEqual(height, expected, accuracy: 0.5)
    }
}
