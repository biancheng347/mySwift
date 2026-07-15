import UIKit

fileprivate let rgb: CGFloat = 255.0

public func UIColor(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
    UIColor(red: r / rgb, green: g / rgb, blue: b / rgb, alpha: alpha)
}

public func ColorFromHex(_ v: Int64, alpha: CGFloat = 1) -> UIColor {
    let r = CGFloat((v & 0xFF0000) >> 16)
    let g = CGFloat((v & 0xFF00) >> 8)
    let b = CGFloat(v & 0xFF)
    return UIColor(r: r, g: g, b: b, alpha: alpha)
}

public extension Int {
    var color: UIColor {
        ColorFromHex(Int64(self))
    }

    func alpha(_ alpha: CGFloat) -> UIColor {
        color.withAlphaComponent(alpha)
    }
}
