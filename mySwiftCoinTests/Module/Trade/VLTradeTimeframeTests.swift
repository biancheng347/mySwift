//
//  VLTradeTimeframeTests.swift
//  交易周期枚举单元测试
//

import XCTest
@testable import mySwiftCoin

final class VLTradeTimeframeTests: XCTestCase {

    /// 默认周期应为 15 分。
    func testDefault_isFifteenMinutes() {
        XCTAssertEqual(VLTradeTimeframe.default, .m15)
    }

    /// 分时图标记应对齐 line。
    func testIsTimeShare_onlyLine() {
        XCTAssertTrue(VLTradeTimeframe.line.isTimeShare)
        XCTAssertFalse(VLTradeTimeframe.m15.isTimeShare)
        XCTAssertFalse(VLTradeTimeframe.h1.isTimeShare)
    }

    /// intervalKey 应对齐常见交易所分辨率。
    func testIntervalKey_matchesExpected() {
        XCTAssertEqual(VLTradeTimeframe.line.intervalKey, "1m")
        XCTAssertEqual(VLTradeTimeframe.m15.intervalKey, "15m")
        XCTAssertEqual(VLTradeTimeframe.h1.intervalKey, "1h")
        XCTAssertEqual(VLTradeTimeframe.h4.intervalKey, "4h")
        XCTAssertEqual(VLTradeTimeframe.d1.intervalKey, "1d")
    }

    /// chips 展示文案顺序应对齐 OKX MVP。
    func testAllCases_displayOrder() {
        let titles = VLTradeTimeframe.allCases.map(\.rawValue)
        XCTAssertEqual(titles, ["分时", "15分", "1时", "4时", "1日", "更多"])
    }

    /// OKX REST bar 大小写应对齐文档。
    func testOkxBar_matchesAPI() {
        XCTAssertEqual(VLTradeTimeframe.line.okxBar, "1m")
        XCTAssertEqual(VLTradeTimeframe.m15.okxBar, "15m")
        XCTAssertEqual(VLTradeTimeframe.h1.okxBar, "1H")
        XCTAssertEqual(VLTradeTimeframe.h4.okxBar, "4H")
        XCTAssertEqual(VLTradeTimeframe.d1.okxBar, "1D")
    }
}
