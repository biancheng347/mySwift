import Foundation
import RxSwift
import RxCocoa

public extension Optional where Wrapped == Int {
    /// Falls back to `0` when optional int is nil.
    var defaultValue: Wrapped { self ?? 0 }
}

public extension Observable {
    /// Observes on main or background scheduler by flag.
    func observeOnThread(isMain: Bool) -> Observable<Element> {
        isMain
            ? observe(on: MainScheduler.instance)
            : observe(on: ConcurrentDispatchQueueScheduler(qos: .utility))
    }

    /// Subscribes on main thread and disposes into the bag.
    func bind(dispose: DisposeBag, result: @escaping (Element) -> Void) {
        observeOnThread(isMain: true)
            .subscribe(onNext: result)
            .disposed(by: dispose)
    }
}
