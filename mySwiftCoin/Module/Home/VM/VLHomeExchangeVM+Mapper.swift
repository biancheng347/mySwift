import Foundation
import Then

/// 将交易所域模型分区映射为异构 `ItemTypeModel` 行。
func toItems(_ items: [VLHomeExchangeListItem]) -> [ItemTypeProtocol] {
    items.map(mapItem)
}

/// 包装单个交易所分区并配置 cell 类型与尺寸。
private func mapItem(_ item: VLHomeExchangeListItem) -> ItemTypeProtocol {
    switch item {
    case .search(let model):
        return ItemTypeModel(data: model).confItem(type: VLHomeCellConfig.search)
    case .assets(let model):
        return ItemTypeModel(data: model).confItem(type: VLHomeCellConfig.assets)
    case .banner(let model):
        return ItemTypeModel(data: model).confItem(type: VLHomeCellConfig.banner)
    case .marketList(let model):
        return ItemTypeModel(data: model).confItem(type: VLHomeCellConfig.marketList)
    case .marketOverview(let model):
        let config = VLHomeCellConfig.marketOverview(
            cardCount: model.cards.count,
            hasEvent: !model.eventTitle.isEmpty
        )
        return ItemTypeModel(data: model).confItem(type: config)
    case .announcement(let model):
        let config = VLHomeCellConfig.announcement(entryCount: model.announcements.count)
        return ItemTypeModel(data: model).confItem(type: config)
    }
}
