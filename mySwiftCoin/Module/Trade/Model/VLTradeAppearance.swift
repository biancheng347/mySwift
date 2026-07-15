import UIKit

/// 交易页颜色令牌，对齐 OKX 深色现货详情。
enum VLTradeAppearance {
    /// 页面背景 `#000000`。
    static let pageBackground = ColorFromHex(0x000000)
    /// 表面卡片 `#121212`。
    static let surface = ColorFromHex(0x121212)
    /// 抬升层 `#1F1F1F`。
    static let elevated = ColorFromHex(0x1F1F1F)
    /// 主文案白色。
    static let textPrimary = ColorFromHex(0xFFFFFF)
    /// 次文案灰色。
    static let textSecondary = ColorFromHex(0xA0A0A0)
    /// 三级文案。
    static let textTertiary = ColorFromHex(0x6E6E6E)
    /// 涨 `#2EBD85`。
    static let up = ColorFromHex(0x2EBD85)
    /// 跌 `#F6465D`。
    static let down = ColorFromHex(0xF6465D)
    /// 盘口买侧深度条。
    static let bidDepth = ColorFromHex(0x2EBD85, alpha: 0.18)
    /// 盘口卖侧深度条。
    static let askDepth = ColorFromHex(0xF6465D, alpha: 0.18)
    /// 选中周期芯片底。
    static let chipSelected = ColorFromHex(0x1F1F1F)
    /// 未选中周期芯片底。
    static let chipNormal = UIColor.clear
}
