//
//  VLHomeVCTests.swift
//  首页 VC 单元测试
//

import UIKit
import XCTest
@testable import mySwiftCoin

final class VLHomeVCTests: XCTestCase {

    private var sut: VLHomeVC!

    override func setUp() {
        super.setUp()
        sut = VLHomeVC()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    /// 页面背景色应为 #000000。
    func testViewDidLoad_backgroundIsBlack() {
        sut.loadViewIfNeeded()
        assertColor(sut.view.backgroundColor, equalsHex: 0x000000)
    }

    /// 视图层级中 VLHomeView 下应包含 VLHomeExchangeView。
    func testViewDidLoad_containsExchangeView() {
        sut.loadViewIfNeeded()
        let homeView = sut.view.subviews.compactMap { $0 as? VLHomeView }.first
        XCTAssertNotNil(homeView, "Expected VLHomeView as subview")
        let exchangeView = findExchangeView(in: homeView)
        XCTAssertNotNil(exchangeView, "Expected VLHomeExchangeView in hierarchy")
    }
}

// MARK: - 辅助方法

private extension VLHomeVCTests {

    /// 在视图树中递归查找 VLHomeExchangeView。
    func findExchangeView(in view: UIView?) -> VLHomeExchangeView? {
        guard let view else { return nil }
        if let match = view as? VLHomeExchangeView { return match }
        for sub in view.subviews {
            if let found = findExchangeView(in: sub) { return found }
        }
        return nil
    }

    /// 比较 UIColor RGB 与 hex（容差 ±1/255）。
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
