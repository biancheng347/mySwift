//
//  VLHomeSearchHintDisplayTests.swift
//  首页搜索栏提示展示映射单元测试
//

import XCTest
@testable import mySwiftCoin

final class VLHomeSearchHintDisplayTests: XCTestCase {

    /// 左侧搜索图标应恒为 magnifyingglass。
    func testLeadingSearchIcon_isConstant() {
        XCTAssertEqual(VLHomeSearchHintDisplay.leadingSearchIconName, "magnifyingglass")
    }

    /// 无提示时回落默认文案，且右侧无图标。
    func testDisplay_nilHint_usesFallbackTextOnly() {
        let display = VLHomeSearchHintDisplay.make(from: nil)
        XCTAssertEqual(display.text, "搜索币种/合约")
        XCTAssertNil(display.trailingIconName)
        XCTAssertFalse(display.showsTrailingIcon)
    }

    /// iconName 为空时仅展示文字。
    func testDisplay_emptyIcon_textOnly() {
        let hint = VLHomeSearchHintModel(text: "搜索币种/合约", iconName: "")
        let display = VLHomeSearchHintDisplay.make(from: hint)
        XCTAssertEqual(display.text, "搜索币种/合约")
        XCTAssertNil(display.trailingIconName)
        XCTAssertFalse(display.showsTrailingIcon)
    }

    /// iconName 仅空白时按无图标处理。
    func testDisplay_whitespaceIcon_textOnly() {
        let hint = VLHomeSearchHintModel(text: "BTC/USDT", iconName: "  ")
        let display = VLHomeSearchHintDisplay.make(from: hint)
        XCTAssertEqual(display.text, "BTC/USDT")
        XCTAssertNil(display.trailingIconName)
    }

    /// iconName 非空时右侧为 icon + 文字。
    func testDisplay_nonEmptyIcon_iconAndText() {
        let hint = VLHomeSearchHintModel(text: "ETH 热门", iconName: "flame")
        let display = VLHomeSearchHintDisplay.make(from: hint)
        XCTAssertEqual(display.text, "ETH 热门")
        XCTAssertEqual(display.trailingIconName, "flame")
        XCTAssertTrue(display.showsTrailingIcon)
    }

    /// 文案为空时回落默认文案，但仍可保留右侧图标。
    func testDisplay_emptyText_usesFallbackKeepingIcon() {
        let hint = VLHomeSearchHintModel(text: "", iconName: "bitcoinsign.circle")
        let display = VLHomeSearchHintDisplay.make(from: hint)
        XCTAssertEqual(display.text, "搜索币种/合约")
        XCTAssertEqual(display.trailingIconName, "bitcoinsign.circle")
    }

    /// mock 第三条应为纯文字占位（覆盖「仅文字」形态）。
    func testMockHints_includeTextOnlyAndIconText() {
        let items = VLHomeExchangeService().mockList()
        guard case .search(let model) = items[0] else {
            return XCTFail("Expected search item first")
        }
        let displays = model.hints.map(VLHomeSearchHintDisplay.make(from:))
        XCTAssertTrue(displays.contains(where: { $0.showsTrailingIcon }))
        XCTAssertTrue(displays.contains(where: { !$0.showsTrailingIcon }))
    }
}
