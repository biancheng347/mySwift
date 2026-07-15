//
//  VLHomeVMTests.swift
//  首页 VM 单元测试
//

import XCTest
import RxSwift
import RxRelay
@testable import mySwiftCoin

final class VLHomeVMTests: XCTestCase {

    private var sut: VLHomeVM!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        sut = VLHomeVM()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        sut = nil
        super.tearDown()
    }

    /// 默认 Tab 为交易所（索引 0）。
    func testInitialTabIsZero() {
        XCTAssertEqual(sut.currentTabIndex.value, 0)
    }

    /// selectTab(1) 切换到 Web3。
    func testSelectTab_switchesToWeb3() {
        sut.selectTab(1)
        XCTAssertEqual(sut.currentTabIndex.value, 1)
    }

    /// 越界 Tab 索引应被忽略。
    func testSelectTab_outOfRangeIsNoOp() {
        sut.selectTab(5)
        XCTAssertEqual(sut.currentTabIndex.value, 0)
        sut.selectTab(-1)
        XCTAssertEqual(sut.currentTabIndex.value, 0)
    }
}
