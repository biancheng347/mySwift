import UIKit

/// 首页交易所列表项的固定与动态 Cell 尺寸。
enum VLHomeCellConfig {
    case search
    case assets
    case banner
    case marketList
    case marketOverview(cardCount: Int, hasEvent: Bool)
    case announcement(entryCount: Int)
}

extension VLHomeCellConfig: ItemTypeConfigProtocol {

    /// 返回 BTCollectionView 映射所需的 cell reuse id、宽高。
    var conf: (type: String, width: Double, height: Double) {
        switch self {
        case .search:
            return (VLHomeSearchCell.str, AppWidth, 44.rpx)
        case .assets:
            return (VLHomeAssetsCell.str, AppWidth, VLHomeLayout.assetsCellHeight)
        case .banner:
            return (VLHomeBannerCell.str, AppWidth, 113.rpx)
        case .marketList:
            return (VLHomeMarketListCell.str, AppWidth, VLHomeLayout.marketListBaseHeight)
        case .marketOverview(_, let hasEvent):
            // 三列横排共享背景，固定一行高度 72。
            let eventHeight = hasEvent ? 44.rpx : 0
            return (VLHomeMarketOverviewCell.str, AppWidth, 36.rpx + 72.rpx + eventHeight + 8.rpx)
        case .announcement(let entryCount):
            // 2(top) + ~20(title) + 8(gap) + rows + 8(bottom)
            let rowsHeight = Double(entryCount) * 64.rpx
            return (VLHomeAnnouncementCell.str, AppWidth, 30.rpx + rowsHeight + 8.rpx)
        }
    }
}
