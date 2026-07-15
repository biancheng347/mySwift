//
//  VLHomeExchangeVMTests.swift
//  首页交易所 VM 单元测试
//

import XCTest
import RxSwift
import RxRelay
@testable import mySwiftCoin

final class VLHomeExchangeVMTests: XCTestCase {

    private var sut: VLHomeExchangeVM!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        sut = VLHomeExchangeVM()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        sut = nil
        super.tearDown()
    }

    /// load() 应填充 listPublisher，共 6 个映射项。
    func testLoad_populatesListPublisher() {
        let exp = expectation(description: "list loaded")
        var received: [ItemTypeProtocol] = []
        sut.listPublisher
            .skip(1)
            .take(1)
            .subscribe(onNext: { items in
                received = items
                exp.fulfill()
            })
            .disposed(by: disposeBag)
        sut.load()
        wait(for: [exp], timeout: 2.0)
        XCTAssertEqual(received.count, 6)
        XCTAssertEqual(received[0].cellTypeStr, VLHomeSearchCell.str)
    }

    /// 首次 load 完成后再二次 load，应再次发布列表。
    func testLoad_againReloadsList() {
        let first = expectation(description: "initial load")
        let second = expectation(description: "second load")
        var emissions = 0
        sut.listPublisher
            .skip(1)
            .subscribe(onNext: { _ in
                emissions += 1
                if emissions == 1 { first.fulfill() }
                if emissions == 2 { second.fulfill() }
            })
            .disposed(by: disposeBag)
        sut.load()
        wait(for: [first], timeout: 2.0)
        sut.load()
        wait(for: [second], timeout: 2.0)
        XCTAssertEqual(sut.listPublisher.value.count, 6)
    }

    /// 快速连续两次 load 应取消进行中的请求，最终仍得到一份 6 项列表。
    func testLoad_cancelsInFlightRequest() {
        let exp = expectation(description: "final list")
        sut.listPublisher
            .skip(1)
            .take(1)
            .subscribe(onNext: { _ in exp.fulfill() })
            .disposed(by: disposeBag)
        sut.load()
        sut.load()
        wait(for: [exp], timeout: 2.0)
        XCTAssertEqual(sut.listPublisher.value.count, 6)
    }

    /// toggleBalanceHidden 应翻转资产模型掩码并再次发布列表。
    func testToggleBalanceHidden_flipsModelAndRepublishes() {
        let loaded = expectation(description: "list loaded")
        sut.listPublisher
            .skip(1)
            .take(1)
            .subscribe(onNext: { _ in loaded.fulfill() })
            .disposed(by: disposeBag)
        sut.load()
        wait(for: [loaded], timeout: 2.0)

        guard let assetsItem = sut.listPublisher.value
            .compactMap({ $0 as? ItemTypeModel<VLHomeAssetsModel> }).first else {
            return XCTFail("Expected assets item")
        }
        XCTAssertFalse(assetsItem.data.isBalanceHidden)

        let republish = expectation(description: "republish")
        sut.listPublisher
            .skip(1)
            .take(1)
            .subscribe(onNext: { _ in republish.fulfill() })
            .disposed(by: disposeBag)
        sut.toggleBalanceHidden()
        wait(for: [republish], timeout: 1.0)
        XCTAssertTrue(assetsItem.data.isBalanceHidden)
    }

    /// selectMarketTab 应更新模型 Tab 索引并重置永续模式。
    func testSelectMarketTab_updatesModelState() {
        let loaded = expectation(description: "list loaded")
        sut.listPublisher
            .skip(1)
            .take(1)
            .subscribe(onNext: { _ in loaded.fulfill() })
            .disposed(by: disposeBag)
        sut.load()
        wait(for: [loaded], timeout: 2.0)

        guard let marketItem = sut.listPublisher.value
            .compactMap({ $0 as? ItemTypeModel<VLHomeMarketListModel> }).first else {
            return XCTFail("Expected market list item")
        }
        sut.selectMarketSwapMode(true)
        sut.selectMarketTab(index: 2)
        XCTAssertEqual(marketItem.data.selectedTabIndex, 2)
        XCTAssertFalse(marketItem.data.isSwapMode)
    }
}
