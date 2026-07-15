//
//  VLMainTabBarVCTests.swift
//  mySwiftCoinTests
//
//  Instantiate VCs directly — no UIApplication / SceneDelegate launch required.
//

import UIKit
import XCTest
@testable import mySwiftCoin

final class VLMainTabBarVCTests: XCTestCase {

    private var sut: VLMainTabBarVC!

    override func setUp() {
        super.setUp()
        sut = VLMainTabBarVC()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Structure after load

    /// Shell must host three root pages after view loads.
    func testViewDidLoad_hasThreeViewControllers() {
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.viewControllers?.count, 3)
    }

    /// Default selected tab is 首页 (index 0).
    func testViewDidLoad_defaultSelectedIndexIsZero() {
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.selectedIndex, 0)
    }

    /// Tab bar item titles mirror VLTabBarItemConfig order.
    func testViewDidLoad_tabBarItemTitlesMatchConfig() {
        sut.loadViewIfNeeded()
        let titles = sut.viewControllers?.map { $0.tabBarItem.title ?? "" }
        XCTAssertEqual(titles, ["首页", "交易", "资产"])
    }

    /// Child roots use the expected Chat-style VC types.
    func testViewDidLoad_childViewControllerTypes() {
        sut.loadViewIfNeeded()
        guard let children = sut.viewControllers else {
            XCTFail("Expected viewControllers")
            return
        }
        XCTAssertTrue(children[0] is VLHomeVC)
        XCTAssertTrue(children[1] is VLTradeVC)
        XCTAssertTrue(children[2] is VLAssetsVC)
    }

    // MARK: - selectTab

    /// selectTab(1) switches to 交易.
    func testSelectTab_changesSelectedIndex() {
        sut.loadViewIfNeeded()
        sut.selectTab(1)
        XCTAssertEqual(sut.selectedIndex, 1)
    }

    /// selectTab(same index) is a no-op (Flutter contract).
    func testSelectTab_sameIndexIsNoOp() {
        sut.loadViewIfNeeded()
        sut.selectTab(1)
        XCTAssertEqual(sut.selectedIndex, 1)
        sut.selectTab(1)
        XCTAssertEqual(sut.selectedIndex, 1)
    }

    /// selectTab(0) when already on 首页 leaves index unchanged.
    func testSelectTab_zeroWhenAlreadyZeroIsNoOp() {
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.selectedIndex, 0)
        sut.selectTab(0)
        XCTAssertEqual(sut.selectedIndex, 0)
    }

    /// selectTab out-of-range indices are ignored.
    func testSelectTab_outOfBoundsIsNoOp() {
        sut.loadViewIfNeeded()
        sut.selectTab(-1)
        XCTAssertEqual(sut.selectedIndex, 0)
        sut.selectTab(3)
        XCTAssertEqual(sut.selectedIndex, 0)
    }

    // MARK: - Dark appearance (#121212 bar, #FFFFFF selected, #8B8B8B unselected, #000000 page)

    /// Tab bar background uses dark shell color #121212.
    func testAppearance_tabBarBackgroundIsDark121212() {
        sut.loadViewIfNeeded()
        // barTintColor is the legacy surface; standardAppearance is iOS 15+ source of truth.
        assertColor(sut.tabBar.barTintColor, equalsHex: 0x121212)
        if #available(iOS 15.0, *) {
            assertColor(sut.tabBar.standardAppearance.backgroundColor, equalsHex: 0x121212)
        }
    }

    /// Selected tab label/icon tint is #FFFFFF.
    func testAppearance_selectedItemColorIsWhite() {
        sut.loadViewIfNeeded()
        if #available(iOS 15.0, *) {
            let appearance = sut.tabBar.standardAppearance
            assertColor(
                appearance.stackedLayoutAppearance.selected.titleTextAttributes[.foregroundColor] as? UIColor,
                equalsHex: 0xFFFFFF
            )
            assertColor(
                appearance.stackedLayoutAppearance.selected.iconColor,
                equalsHex: 0xFFFFFF
            )
        } else {
            assertColor(sut.tabBar.tintColor, equalsHex: 0xFFFFFF)
        }
    }

    /// Unselected tab label/icon tint is #B0B0B0.
    func testAppearance_unselectedItemColorIsGray8B8B8B() {
        sut.loadViewIfNeeded()
        if #available(iOS 15.0, *) {
            let appearance = sut.tabBar.standardAppearance
            assertColor(
                appearance.stackedLayoutAppearance.normal.titleTextAttributes[.foregroundColor] as? UIColor,
                equalsHex: 0xB0B0B0
            )
            assertColor(
                appearance.stackedLayoutAppearance.normal.iconColor,
                equalsHex: 0xB0B0B0
            )
        } else {
            assertColor(sut.tabBar.unselectedItemTintColor, equalsHex: 0xB0B0B0)
        }
    }

    /// Each child page background is #000000.
    func testAppearance_childViewBackgroundsAreBlack() {
        sut.loadViewIfNeeded()
        sut.viewControllers?.forEach { child in
            child.loadViewIfNeeded()
            assertColor(child.view.backgroundColor, equalsHex: 0x000000)
        }
    }
}

// MARK: - Color assertion helper

private extension VLMainTabBarVCTests {

    /// Compares UIColor RGB components to a 24-bit hex value (sRGB, ±1/255 tolerance).
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
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        XCTAssertTrue(
            color.getRed(&r, green: &g, blue: &b, alpha: &a),
            "Color must convert to sRGB",
            file: file,
            line: line
        )
        let expectedR = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let expectedG = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let expectedB = CGFloat(hex & 0xFF) / 255.0
        XCTAssertEqual(r, expectedR, accuracy: accuracy, "Red mismatch for #\(String(hex, radix: 16))", file: file, line: line)
        XCTAssertEqual(g, expectedG, accuracy: accuracy, "Green mismatch for #\(String(hex, radix: 16))", file: file, line: line)
        XCTAssertEqual(b, expectedB, accuracy: accuracy, "Blue mismatch for #\(String(hex, radix: 16))", file: file, line: line)
    }
}
