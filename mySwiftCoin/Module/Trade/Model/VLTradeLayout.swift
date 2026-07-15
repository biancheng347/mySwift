import UIKit

/// 交易页布局与文案令牌。
enum VLTradeLayout {
    /// 左右边距。
    static let horizontalInset: CGFloat = 12.rpx
    /// 顶部分类栏高度。
    static let categoryBarHeight: CGFloat = 44.rpx
    /// 交易对栏高度。
    static let symbolBarHeight: CGFloat = 44.rpx
    /// Header 区高度估算。
    static let headerHeight: CGFloat = 88.rpx
    /// 周期栏高度。
    static let timeframeHeight: CGFloat = 36.rpx
    /// K 线主图高度。
    static let klineMainHeight: CGFloat = 220.rpx
    /// 成交量子图高度。
    static let klineVolumeHeight: CGFloat = 56.rpx
    /// 时间轴高度。
    static let klineTimeHeight: CGFloat = 18.rpx
    /// K 线整块高度（主+量+时间+间距）。
    static var klineBlockHeight: CGFloat {
        klineMainHeight + klineVolumeHeight + klineTimeHeight + 8.rpx
    }
    /// 盘口单行高度。
    static let orderBookRowHeight: CGFloat = 20.rpx
    /// 盘口展示档位数（对齐 OKX books5）。
    static let orderBookLevels: Int = 5
    /// 合约盘口 mock 可扩展档位（右侧展示仍取 books5）。
    static let futuresOrderBookMockLevels: Int = 12
    /// 底部 Tab 高度。
    static let bottomTabHeight: CGFloat = 40.rpx
    /// 持仓卡近似高度。
    static let positionCardHeight: CGFloat = 168.rpx
    /// 委托行高度。
    static let openOrderRowHeight: CGFloat = 88.rpx
    /// 资产行高度。
    static let assetRowHeight: CGFloat = 72.rpx
    /// 底部列表最大可视高度。
    static let bottomListMaxHeight: CGFloat = 280.rpx
    /// 买卖表单区最小高度。
    static let orderFormMinHeight: CGFloat = 280.rpx
    /// 表单与盘口左右比例（左表单略窄）。
    static let formWidthRatio: CGFloat = 0.48
    /// 交易页控件圆角（对齐 OKX App 圆角按钮）。
    static let buttonCornerRadius: CGFloat = 8.rpx
    /// 侧栏买卖分段圆角。
    static let sideButtonCornerRadius: CGFloat = 8.rpx
    /// 交易页滚动区 K 线可视高度（主图+量+时间，紧凑版）。
    static let tradePanelKlineHeight: CGFloat = 198.rpx
    /// 紧凑主图高度。
    static let klineMainHeightCompact: CGFloat = 132.rpx
    /// 紧凑成交量高度。
    static let klineVolumeHeightCompact: CGFloat = 44.rpx
    /// 紧凑时间轴高度。
    static let klineTimeHeightCompact: CGFloat = 16.rpx
}
