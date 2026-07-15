//
//  VLTradeMarginModeTests.swift
//  合约全仓/逐仓 VM 测试
//

import XCTest
import RxSwift
import RxRelay
@testable import mySwiftCoin

final class VLTradeMarginModeTests: XCTestCase {

    private var sut: VLTradeVM!

    override func setUp() {
        super.setUp()
        sut = VLTradeVM(useLiveSocket: false)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    /// 默认全仓。
    func testDefault_isCrossMargin() {
        XCTAssertTrue(sut.formPublisher.value.isCrossMargin)
    }

    /// selectMarginMode 应切换全仓/逐仓。
    func testSelectMarginMode_toggles() {
        sut.selectMarginMode(isCross: false)
        XCTAssertFalse(sut.formPublisher.value.isCrossMargin)
        sut.selectMarginMode(isCross: true)
        XCTAssertTrue(sut.formPublisher.value.isCrossMargin)
    }

    /// selectSymbol 应切换 BTC / ETH 并清空旧 ticker。
    func testSelectSymbol_switchesETH() {
        sut.selectSymbol("ETH/USDT")
        XCTAssertEqual(sut.symbol, "ETH/USDT")
        XCTAssertEqual(sut.symbolPublisher.value, "ETH/USDT")
    }

    /// 非法交易对应忽略。
    func testSelectSymbol_ignoresUnknown() {
        sut.selectSymbol("DOGE/USDT")
        XCTAssertEqual(sut.symbol, "BTC/USDT")
    }
}
