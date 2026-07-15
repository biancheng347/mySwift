//
//  VLTradeVMTests.swift
//  交易页 VM 单元测试
//

import XCTest
import RxSwift
import RxRelay
@testable import mySwiftCoin

final class VLTradeVMTests: XCTestCase {

    private var sut: VLTradeVM!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        sut = VLTradeVM(useLiveSocket: false)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        sut = nil
        super.tearDown()
    }

    /// load() 应填充 ticker、candles、orderBook。
    func testLoad_populatesPublishers() {
        let tickerExp = expectation(description: "ticker")
        let candlesExp = expectation(description: "candles")
        let bookExp = expectation(description: "book")

        sut.tickerPublisher.skip(1).take(1).subscribe(onNext: { value in
            XCTAssertNotNil(value)
            XCTAssertFalse(value?.lastPrice.isEmpty ?? true)
            tickerExp.fulfill()
        }).disposed(by: disposeBag)

        sut.candlesPublisher.skip(1).take(1).subscribe(onNext: { candles in
            XCTAssertGreaterThanOrEqual(candles.count, 80)
            candlesExp.fulfill()
        }).disposed(by: disposeBag)

        sut.orderBookPublisher.skip(1).take(1).subscribe(onNext: { book in
            XCTAssertNotNil(book)
            XCTAssertEqual(book?.bids.count, VLTradeLayout.orderBookLevels)
            bookExp.fulfill()
        }).disposed(by: disposeBag)

        sut.load()
        wait(for: [tickerExp, candlesExp, bookExp], timeout: 2.0)
    }

    /// selectCategory 应切换分类且不改变为闪兑时仍保留行情数据通道。
    func testSelectCategory_updatesPublisher() {
        sut.selectCategory(.futures)
        XCTAssertEqual(sut.categoryPublisher.value, .futures)
        sut.selectCategory(.strategy)
        XCTAssertEqual(sut.categoryPublisher.value, .strategy)
        sut.selectCategory(.spot)
        XCTAssertEqual(sut.categoryPublisher.value, .spot)
    }

    /// selectTimeframe 应更新周期并重载蜡烛。
    func testSelectTimeframe_reloadsCandles() {
        let loaded = expectation(description: "initial")
        sut.candlesPublisher.skip(1).take(1).subscribe(onNext: { _ in loaded.fulfill() })
            .disposed(by: disposeBag)
        sut.load()
        wait(for: [loaded], timeout: 2.0)

        let reloaded = expectation(description: "reload")
        sut.candlesPublisher.skip(1).take(1).subscribe(onNext: { candles in
            XCTAssertGreaterThanOrEqual(candles.count, 80)
            reloaded.fulfill()
        }).disposed(by: disposeBag)

        sut.selectTimeframe(.h1)
        wait(for: [reloaded], timeout: 2.0)
        XCTAssertEqual(sut.timeframePublisher.value, .h1)
    }

    /// 「更多」不应改变当前周期。
    func testSelectTimeframe_moreIsNoOp() {
        sut.selectTimeframe(.more)
        XCTAssertEqual(sut.timeframePublisher.value, .m15)
    }

    /// selectSide 应更新表单买卖方向。
    func testSelectSide_updatesForm() {
        sut.selectSide(.sell)
        XCTAssertEqual(sut.formPublisher.value.side, .sell)
        sut.selectSide(.buy)
        XCTAssertEqual(sut.formPublisher.value.side, .buy)
    }

    /// 快速连续切换周期应仍得到有效蜡烛（flatMapLatest 取消 in-flight）。
    func testSelectTimeframe_cancelsInFlight() {
        let exp = expectation(description: "final candles")
        sut.candlesPublisher
            .skip(1)
            .filter { $0.count >= 80 }
            .take(1)
            .subscribe(onNext: { _ in exp.fulfill() })
            .disposed(by: disposeBag)
        sut.selectTimeframe(.m15)
        sut.selectTimeframe(.h1)
        sut.selectTimeframe(.d1)
        wait(for: [exp], timeout: 2.0)
        XCTAssertEqual(sut.timeframePublisher.value, .d1)
        XCTAssertGreaterThanOrEqual(sut.candlesPublisher.value.count, 80)
    }

    /// 切合约后底部默认持仓 Tab，且账户 mock 非空。
    func testSelectCategory_futuresLoadsAccount() {
        let exp = expectation(description: "account")
        sut.accountPublisher
            .skip(1)
            .filter { !$0.positions.isEmpty }
            .take(1)
            .subscribe(onNext: { snap in
                XCTAssertFalse(snap.openOrders.isEmpty)
                exp.fulfill()
            })
            .disposed(by: disposeBag)
        sut.selectCategory(.futures)
        wait(for: [exp], timeout: 2.0)
        XCTAssertEqual(sut.bottomTabPublisher.value, .positions)
    }

    /// 底部 Tab 切换（现货仅委托/资产，持仓应被忽略）。
    func testSelectBottomTab_spotAllowsAssets() {
        sut.selectBottomTab(.assets)
        XCTAssertEqual(sut.bottomTabPublisher.value, .assets)
        sut.selectBottomTab(.positions)
        XCTAssertEqual(sut.bottomTabPublisher.value, .assets)
    }
}
