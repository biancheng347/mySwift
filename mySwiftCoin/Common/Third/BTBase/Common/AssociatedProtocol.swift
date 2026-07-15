
import UIKit

public protocol AssociatedProtocol {
    var policy: objc_AssociationPolicy { get }
}

public extension AssociatedProtocol {
    @inline(__always)
    func associatedObject<T>(forKey key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(self, key) as? T
    }
    
    @inline(__always)
    func associatedObject<T>(forKey key: UnsafeRawPointer, default: @autoclosure () -> T) -> T {
        if let object: T = self.associatedObject(forKey: key) {
            return object
        }
        let object = `default`()
        self.setAssociatedObject(object, forKey: key)
        return object
    }
    
    @inline(__always)
    func setAssociatedObject<T>(_ object: T?, forKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, object, policy)
    }
}





public protocol AssociatedStrongProtocol: AssociatedProtocol{ }
extension AssociatedStrongProtocol {
    public var policy: objc_AssociationPolicy {
        return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    }
}


public protocol AssociatedAssignProtocol: AssociatedProtocol { }
extension AssociatedAssignProtocol {
    public var policy: objc_AssociationPolicy {
        return .OBJC_ASSOCIATION_ASSIGN
    }
}


public protocol AssociatedCopyProtocol: AssociatedProtocol { }
extension AssociatedCopyProtocol {
    public var policy: objc_AssociationPolicy {
        return .OBJC_ASSOCIATION_COPY_NONATOMIC
    }
}

