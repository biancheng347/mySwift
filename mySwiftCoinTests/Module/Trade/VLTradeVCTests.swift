//
//  VLTradeVCTests.swift
//  交易页 VC 单元测试
//

import UIKit
import XCTest
@testable import mySwiftCoin

final class VLTradeVCTests: XCTestCase {

    private var sut: VLTradeVC!

    override func setUp() {
        super.setUp()
        sut = VLTradeVC()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    /// 页面背景应为 OKX 黑色。
    func testViewDidLoad_backgroundIsBlack() {
        sut.loadViewIfNeeded()
        assertColor(sut.view.backgroundColor, equalsHex: 0x000000)
    }

    /// 根视图应包含 VLTradeView。
    func testViewDidLoad_containsTradeView() {
        sut.loadViewIfNeeded()
        let tradeView = sut.view.subviews.compactMap { $0 as? VLTradeView }.first
        XCTAssertNotNil(tradeView)
    }

    /// 应包含分类栏（点击切换，非滑动 Page）。
    func testViewDidLoad_containsCategoryBar() {
        sut.loadViewIfNeeded()
        let tradeView = sut.view.subviews.compactMap { $0 as? VLTradeView }.first
        let bar = findView(VLTradeCategoryBar.self, in: tradeView)
        XCTAssertNotNil(bar, "Expected VLTradeCategoryBar")
    }

    /// 现货面板应含表单与盘口。
    func testViewDidLoad_containsMarketPanel() {
        sut.loadViewIfNeeded()
        let tradeView = sut.view.subviews.compactMap { $0 as? VLTradeView }.first
        XCTAssertNotNil(findView(VLTradeMarketPanelView.self, in: tradeView))
        XCTAssertNotNil(findView(VLTradeOrderFormView.self, in: tradeView))
        XCTAssertNotNil(findView(VLTradeOrderBookView.self, in: tradeView))
    }
}

private extension VLTradeVCTests {

    /// 递归按类型查找子视图。
    func findView<T: UIView>(_ type: T.Type, in view: UIView?) -> T? {
        guard let view else { return nil }
        if let match = view as? T { return match }
        for sub in view.subviews {
            if let found = findView(type, in: sub) { return found }
        }
        return nil
    }

    /// 比较 UIColor 与 hex。
    func assertColor(
        _ color: UIColor?,
        equalsHex hex: Int64,
        accuracy: CGFloat = 1.0 / 255.0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let color else {
            XCTFail("Expected UIColor, got nil", file: file, line: line)
            return
        }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        XCTAssertTrue(color.getRed(&r, green: &g, blue: &b, alpha: &a), file: file, line: line)
        let expectedR = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let expectedG = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let expectedB = CGFloat(hex & 0xFF) / 255.0
        XCTAssertEqual(r, expectedR, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(g, expectedG, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(b, expectedB, accuracy: accuracy, file: file, line: line)
    }
}
