import UIKit

/// Dark tab-bar color tokens matching Flutter mycoin.
enum VLTabBarAppearance {
    /// Page / scaffold background `#000000`.
    static let pageBackground = ColorFromHex(0x000000)
    /// Tab bar surface `#121212`.
    static let barBackground = ColorFromHex(0x121212)
    /// Selected icon and title `#FFFFFF`.
    static let selected = ColorFromHex(0xFFFFFF)
    /// Unselected icon and title `#B0B0B0`（深色底上提高对比）。
    static let unselected = ColorFromHex(0xB0B0B0)
}
