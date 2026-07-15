import Foundation
import RxSwift
import RxCocoa

/// 首页 Tab 状态（交易所 / Web3）。
final class VLHomeVM: DisposeProtocol, WeakHandleProtocol {

    /// 当前选中分段索引（0 = 交易所，1 = Web3）。
    private(set) lazy var currentTabIndex = BehaviorRelay<Int>(value: 0)

    /// 索引合法时切换首页分段。
    func selectTab(_ index: Int) {
        guard (0...1).contains(index) else { return }
        currentTabIndex.accept(index)
    }
}
