import UIKit
import SnapKit

public let AppFrame = UIScreen.main.bounds
public let AppWidth = UIScreen.main.bounds.width
public let AppHeight = UIScreen.main.bounds.height

@inline(__always)
public func currentDevice<T>(phone: @autoclosure () -> T,
                             pad: @autoclosure () -> T) -> T {
    switch UIDevice.current.userInterfaceIdiom {
    case .phone: return phone()
    case .pad: return pad()
    default: fatalError()
    }
}

public extension UIView {
    @discardableResult
    func make(_ view: UIView, _ closure: (ConstraintMaker) -> Void) -> Self {
        assert(Thread.isMainThread)
        view.addSubview(self)
        self.snp.makeConstraints(closure)
        return self
    }

    @discardableResult
    func update(_ closure: (ConstraintMaker) -> Void) -> Self {
        assert(Thread.isMainThread)
        self.snp.updateConstraints(closure)
        return self
    }
}

// MARK: - rpx
fileprivate let standard: CGFloat = 375
fileprivate let factor = AppWidth / standard
fileprivate let Hstandard: CGFloat = 768.0
fileprivate let Hfactor = AppHeight / Hstandard

public extension Int {
    @inline(__always)
    var rpx: CGFloat {
        currentDevice(phone: factor, pad: Hfactor) * CGFloat(self)
    }
}

public extension Double {
    @inline(__always)
    var rpx: CGFloat {
        currentDevice(phone: factor, pad: Hfactor) * CGFloat(self)
    }
}

public extension CGFloat {
    @inline(__always)
    var rpx: CGFloat {
        currentDevice(phone: factor, pad: Hfactor) * self
    }
}
