import RxSwift
import RxCocoa

private struct ActivityToken<E>: ObservableConvertibleType, Disposable {
    
    private let _source: Observable<E>
    private let _dispose: Cancelable
    
    init(source: Observable<E>, disposeAction: @escaping () -> Void) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }
    
    func dispose() {
        _dispose.dispose()
    }
    
    func asObservable() -> Observable<E> {
        return _source
    }
}


public class ActivityLoading: SharedSequenceConvertibleType {
    
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy
    
    private let _lock = NSRecursiveLock()
    private let _relay = BehaviorRelay<Int?>(value: nil)
    private let _loading: SharedSequence<SharingStrategy, Bool>
    
    public init() {
        _loading = _relay
            .asDriver()
            .compactMap { $0 }
            .map { $0 > 0 }
            .distinctUntilChanged()
    }
    
    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _loading
    }
    
    fileprivate func trackActivityOfObservable<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        return Observable.using({ () -> ActivityToken<Source.Element> in
            self.increment()
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }, observableFactory: { value in
            return value.asObservable()
        })
    }
    
    private func increment() {
        _lock.lock()
        defer { _lock.unlock() }
        _relay.accept(_relay.value.defaultValue + 1)
    }
    
    private func decrement() {
        _lock.lock()
        defer { _lock.unlock() }
        _relay.accept(_relay.value.defaultValue - 1)
    }
}

extension ObservableConvertibleType {
    
    public func trackLoading(_ activityLoading: ActivityLoading) -> Observable<Element> {
        return activityLoading.trackActivityOfObservable(self)
    }
}





