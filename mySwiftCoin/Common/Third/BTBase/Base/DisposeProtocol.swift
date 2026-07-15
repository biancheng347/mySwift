import Foundation
import RxSwift

fileprivate var _DISPOSEBAG_KEY: Void?

/// Associates an `DisposeBag` with any `AssociatedStrongProtocol` object.
public protocol DisposeProtocol: AssociatedStrongProtocol {
    var disposeBag: DisposeBag { get set }
}

extension DisposeProtocol {
    public var disposeBag: DisposeBag {
        set { setAssociatedObject(newValue, forKey: &_DISPOSEBAG_KEY) }
        get { associatedObject(forKey: &_DISPOSEBAG_KEY, default: DisposeBag()) }
    }
}

extension NSObject: DisposeProtocol {}
