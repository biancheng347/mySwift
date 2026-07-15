import UIKit

/// 首页 OKX 风格布局令牌（边距、行列高、列头文案）。
enum VLHomeLayout {
    /// 左右常规边距。
    static let horizontalInset: CGFloat = 16.rpx
    /// 涨跌幅徽章宽度。
    static let changeBadgeWidth: CGFloat = 72.rpx
    /// 涨跌幅徽章高度。
    static let changeBadgeHeight: CGFloat = 28.rpx
    /// 行情币种行高度。
    static let coinRowHeight: CGFloat = 56.rpx
    /// 行情列头高度。
    static let columnHeaderHeight: CGFloat = 28.rpx
    /// 列头：名称。
    static let columnNameTitle = "名称"
    /// 列头：最新价。
    static let columnPriceTitle = "最新价"
    /// 列头：涨跌幅。
    static let columnChangeTitle = "涨跌幅"
    /// 资产 Cell 高度（含「预估总资产」层级）。
    static let assetsCellHeight: CGFloat = 148.rpx

    /// 行情列表 Cell 基础高度：外边距 + Tab + 列头间距 + 列头 + 5 行 + 更多。
    static var marketListBaseHeight: CGFloat {
        let outerVertical: CGFloat = 16.rpx
        let tabBlock: CGFloat = 40.rpx
        let headerGap: CGFloat = 4.rpx
        let rows: CGFloat = coinRowHeight * 5
        let moreBlock: CGFloat = 52.rpx
        return outerVertical + tabBlock + headerGap + columnHeaderHeight + rows + moreBlock
    }
}
