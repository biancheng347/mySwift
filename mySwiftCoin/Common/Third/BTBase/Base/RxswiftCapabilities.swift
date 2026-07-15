import Foundation
import UIKit
import RxSwift
import RxCocoa

fileprivate var _RXSWIFT_ERROR: Void?
fileprivate var _RXSWIFT_REFRESH: Void?
fileprivate var _RXSWIFT_LOADING: Void?

/// VM capability: emit user-facing errors via `ErrorWorker`.
public protocol RxswiftError: AssociatedStrongProtocol {
    var error: ErrorWorker { get set }
}

extension RxswiftError {
    public var error: ErrorWorker {
        set { setAssociatedObject(newValue, forKey: &_RXSWIFT_ERROR) }
        get { associatedObject(forKey: &_RXSWIFT_ERROR, default: ErrorWorker()) }
    }
}

extension ErrorWorker {
    /// Bind errors to a closure without Toast/HUD dependency.
    public func bind(dispose: DisposeBag, weakError: @escaping (Error) -> Void) {
        asObservable().observeOnThread(isMain: true).subscribe(onNext: weakError).disposed(by: dispose)
    }
}

/// VM capability: signal pull-to-refresh completion.
public protocol RxswiftRefresh: AssociatedStrongProtocol {
    var refresh: RefreshWorker { get set }
}

extension RxswiftRefresh {
    public var refresh: RefreshWorker {
        set { setAssociatedObject(newValue, forKey: &_RXSWIFT_REFRESH) }
        get { associatedObject(forKey: &_RXSWIFT_REFRESH, default: RefreshWorker()) }
    }
}

extension RefreshWorker {
    /// End MJRefresh header when refresh worker fires.
    public func bind(dispose: DisposeBag, collectionView: UICollectionView) {
        asObservable()
            .observeOnThread(isMain: true)
            .subscribe(onNext: collectionView.weakHandle { $0?.refresh(state: .endHeaderRefresh) })
            .disposed(by: dispose)
    }
}

/// VM capability: track in-flight loading via `ActivityLoading`.
public protocol RxswiftLoading: AssociatedStrongProtocol {
    var loading: ActivityLoading { get set }
}

extension RxswiftLoading {
    public var loading: ActivityLoading {
        set { setAssociatedObject(newValue, forKey: &_RXSWIFT_LOADING) }
        get { associatedObject(forKey: &_RXSWIFT_LOADING, default: ActivityLoading()) }
    }
}

extension ActivityLoading {
    /// Bind loading state to a closure (spinner / overlay).
    public func bind(dispose: DisposeBag, weakLoading: @escaping (Bool) -> Void) {
        asObservable().observeOnThread(isMain: true).subscribe(onNext: weakLoading).disposed(by: dispose)
    }
}
