import Foundation
import RxSwift

/// 提供首页交易所列表数据（Phase 1 使用 mock）。
final class VLHomeExchangeService {

    /// 拉取交易所首页列表，带短延迟模拟。
    func getList() -> Observable<[VLHomeExchangeListItem]> {
        Observable.create { observer in
            let work = DispatchWorkItem {
                observer.onNext(self.mockList())
                observer.onCompleted()
            }
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.4, execute: work)
            return Disposables.create { work.cancel() }
        }
    }

    /// 返回与 Flutter `HomeExchangeProvider.mockList` 一致的静态 mock 列表。
    func mockList() -> [VLHomeExchangeListItem] {
        VLHomeExchangeMockData.items
    }
}
