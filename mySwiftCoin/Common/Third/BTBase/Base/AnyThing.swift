import UIKit

public extension Optional {
    /// 安全向下转型。
    func asObjc<T>(_ type: T.Type) -> T? {
        self as? T
    }
}
