import UIKit

fileprivate var _WEAK_VC_KEY: Void?

fileprivate class _WeakCacheVC {
    weak var _weakVC: UIViewController?
}

fileprivate extension UIView {
    var _weakCacheVC: _WeakCacheVC {
        set { setAssociatedObject(newValue, forKey: &_WEAK_VC_KEY) }
        get { associatedObject(forKey: &_WEAK_VC_KEY, default: _WeakCacheVC()) }
    }
}

public extension UIView {
    /// 向上查找所属 VC，并缓存弱引用。
    var viewCacheVC: UIViewController? {
        var view: UIView? = self
        while view != nil {
            if let cached = view?._weakCacheVC._weakVC { return cached }
            if let vc = view?.next as? UIViewController {
                _weakCacheVC._weakVC = vc
                return vc
            }
            if let win = view?.next as? UIWindow {
                _weakCacheVC._weakVC = win.rootViewController
                return win.rootViewController
            }
            view = view?.superview
        }
        return nil
    }
}
