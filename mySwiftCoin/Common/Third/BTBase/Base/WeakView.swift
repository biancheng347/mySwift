
import UIKit

fileprivate class WeakViewCenter {
    lazy var hashMapTable = NSMapTable<NSString, UIView>.strongToWeakObjects()
}

fileprivate extension WeakViewCenter {
    func set(view: UIView) {
        let key: NSString = NSString(string: type(of: view).str)
        hashMapTable.setObject(view, forKey: key)
    }
    
    func set(key: String, view: UIView) {
        let key: NSString = NSString(string: key)
        hashMapTable.setObject(view, forKey: key)
    }
}


fileprivate extension WeakViewCenter {
    func get(view key: String) -> UIView? {
        let key: NSString = NSString(string: key)
        return hashMapTable.object(forKey: key)
    }
}


fileprivate extension UIView {
    func _registerViewToWeakViewCenter(_ closure: @escaping (UIViewController) -> Void) {
        frameTime {
            $0.viewCacheVC.map(closure)
        }
    }
}







public extension UIView {
    func weakView(register view: UIView, _ completed: (() -> Void)? = nil) {
        _registerViewToWeakViewCenter {
            $0.weakViewCenter.set(view: view)
            completed?()
        }
    }

    func weakView<T: UIView>(fetch type: T.Type) -> T? {
        let key = type.str
        return  viewCacheVC?.weakViewCenter.get(view: key).asObjc(T.self)
    }

    func weakView(set key: String, view: UIView) {
        viewCacheVC?.weakView(set: key, view: view)
    }
    
    func weakView(get key: String) -> UIView? {
        return viewCacheVC?.weakView(get: key)
    }
}







public extension UIViewController {
    func weakView<T: UIView>(fetch type: T.Type) -> T? {
        let key = type.str
        return weakViewCenter.get(view: key).asObjc(T.self)
    }

    func weakView(set key: String, view: UIView) {
        weakViewCenter.set(key: key, view: view)
    }

    func weakView(get key: String) -> UIView? {
        return weakViewCenter.get(view: key)
    }
}







//fileprivate var _WEAK_VIEW_CENTER_KEY = "UIViewController._WEAK_VIEW_CENTER_KEY"
fileprivate var _WEAK_VIEW_CENTER_KEY: Void?

fileprivate extension UIViewController {
     var weakViewCenter: WeakViewCenter {
        set { self.setAssociatedObject(newValue, forKey: &_WEAK_VIEW_CENTER_KEY) }
        get { return self.associatedObject(forKey: &_WEAK_VIEW_CENTER_KEY, default: WeakViewCenter()) }
    }
}

