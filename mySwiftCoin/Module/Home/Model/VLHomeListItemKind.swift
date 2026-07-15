import Foundation

/// 标识各首页交易所列表分区，对应 Flutter `Home*Item.type`。
enum VLHomeListItemKind: String, CaseIterable {
    case search
    case assets
    case banner
    case marketList
    case marketOverview
    case announcement
}
