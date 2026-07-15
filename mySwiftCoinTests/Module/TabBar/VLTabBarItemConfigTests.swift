//
//  VLTabBarItemConfigTests.swift
//  mySwiftCoinTests
//

import XCTest
@testable import mySwiftCoin

final class VLTabBarItemConfigTests: XCTestCase {

    // MARK: - Tab count

    /// Default tab configuration must expose exactly three tabs (Flutter mycoin contract).
    func testDefaultTabs_hasExactlyThreeItems() {
        let tabs = VLTabBarItemConfig.defaultTabs
        XCTAssertEqual(tabs.count, 3)
    }

    // MARK: - Titles (order: 首页, 交易, 资产)

    /// Tab titles must match Flutter mycoin order.
    func testDefaultTabs_titlesMatchFlutterOrder() {
        let titles = VLTabBarItemConfig.defaultTabs.map(\.title)
        XCTAssertEqual(titles, ["首页", "交易", "资产"])
    }

    // MARK: - Indices (0, 1, 2)

    /// Each tab config carries a stable zero-based index.
    func testDefaultTabs_indicesAreZeroOneTwo() {
        let indices = VLTabBarItemConfig.defaultTabs.map(\.index)
        XCTAssertEqual(indices, [0, 1, 2])
    }

    /// Indices must align with array position for predictable selectTab routing.
    func testDefaultTabs_indexMatchesArrayPosition() {
        for (position, config) in VLTabBarItemConfig.defaultTabs.enumerated() {
            XCTAssertEqual(config.index, position)
        }
    }

    // MARK: - Immutability / identity

    /// Repeated access returns equivalent tab definitions (immutable config).
    func testDefaultTabs_isStableAcrossReads() {
        let first = VLTabBarItemConfig.defaultTabs
        let second = VLTabBarItemConfig.defaultTabs
        XCTAssertEqual(first, second)
    }

    /// Every tab must declare a non-empty SF Symbol name for bar items.
    func testDefaultTabs_eachHasSystemImageName() {
        for config in VLTabBarItemConfig.defaultTabs {
            XCTAssertFalse(config.systemImageName.isEmpty)
        }
    }
}
