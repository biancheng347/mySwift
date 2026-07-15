import Foundation
import Then

/// 按 Flutter 列表顺序标记的六个首页交易所分区。
enum VLHomeExchangeListItem {
    case search(VLHomeSearchModel)
    case assets(VLHomeAssetsModel)
    case banner(VLHomeBannerModel)
    case marketList(VLHomeMarketListModel)
    case marketOverview(VLHomeMarketOverviewModel)
    case announcement(VLHomeAnnouncementModel)

    /// 映射为 Flutter 风格的 kind 标识。
    var kind: VLHomeListItemKind {
        switch self {
        case .search: return .search
        case .assets: return .assets
        case .banner: return .banner
        case .marketList: return .marketList
        case .marketOverview: return .marketOverview
        case .announcement: return .announcement
        }
    }
}

/// 搜索栏提示行模型。
final class VLHomeSearchModel: Then {
    var hints: [VLHomeSearchHintModel] = []

    /// 默认空模型，供 Then 链式配置。
    init() {}

    /// 便捷初始化，供 mock 与测试使用。
    convenience init(hints: [VLHomeSearchHintModel]) {
        self.init()
        self.hints = hints
    }
}

/// 单条轮播搜索提示芯片。
final class VLHomeSearchHintModel: Then {
    var text: String = ""
    var iconName: String = ""

    init() {}

    convenience init(text: String, iconName: String) {
        self.init()
        self.text = text
        self.iconName = iconName
    }
}

/// 资产卡片，含多币种选项与余额掩码 UI 状态。
final class VLHomeAssetsModel: Then {
    var currencies: [VLHomeAssetsCurrencyModel] = []
    var isBalanceHidden: Bool = false

    init() {}

    convenience init(currencies: [VLHomeAssetsCurrencyModel]) {
        self.init()
        self.currencies = currencies
    }
}

/// 资产卡片内单个币种余额选项。
final class VLHomeAssetsCurrencyModel: Then {
    var symbol: String = ""
    var totalValue: String = ""
    var todayProfit: String = ""
    var todayProfitRate: String = ""
    var isProfitPositive: Bool = false
    var chartPoints: [Double] = []

    init() {}

    convenience init(
        symbol: String,
        totalValue: String,
        todayProfit: String,
        todayProfitRate: String,
        isProfitPositive: Bool,
        chartPoints: [Double]
    ) {
        self.init()
        self.symbol = symbol
        self.totalValue = totalValue
        self.todayProfit = todayProfit
        self.todayProfitRate = todayProfitRate
        self.isProfitPositive = isProfitPositive
        self.chartPoints = chartPoints
    }
}

/// 促销 Banner 轮播模型。
final class VLHomeBannerModel: Then {
    var banners: [VLHomeBannerSlideModel] = []

    init() {}

    convenience init(banners: [VLHomeBannerSlideModel]) {
        self.init()
        self.banners = banners
    }
}

/// 单张 Banner 幻灯片内容。
final class VLHomeBannerSlideModel: Then {
    var iconName: String = ""
    var title: String = ""
    var subtitle: String = ""

    init() {}

    convenience init(iconName: String, title: String, subtitle: String) {
        self.init()
        self.iconName = iconName
        self.title = title
        self.subtitle = subtitle
    }
}

/// 行情列表分区，含 Tab 化币种排行与 Tab/模式 UI 状态。
final class VLHomeMarketListModel: Then {
    var tabs: [VLHomeMarketListTabModel] = []
    var selectedTabIndex: Int = 0
    var isSwapMode: Bool = false

    init() {}

    convenience init(tabs: [VLHomeMarketListTabModel]) {
        self.init()
        self.tabs = tabs
    }
}

/// 单个行情 Tab（自选、热门榜等）。
final class VLHomeMarketListTabModel: Then {
    var title: String = ""
    var showSpotSwapToggle: Bool = false
    var spotRows: [VLHomeMarketCoinRowModel] = []
    var swapRows: [VLHomeMarketCoinRowModel] = []

    init() {}

    /// 构建仅含现货行的 Tab（Flutter 默认形态）。
    convenience init(
        title: String,
        showSpotSwapToggle: Bool = false,
        spotRows: [VLHomeMarketCoinRowModel],
        swapRows: [VLHomeMarketCoinRowModel] = []
    ) {
        self.init()
        self.title = title
        self.showSpotSwapToggle = showSpotSwapToggle
        self.spotRows = spotRows
        self.swapRows = swapRows
    }
}

/// 行情 Tab 内单行币种数据。
final class VLHomeMarketCoinRowModel: Then {
    var pair: String = ""
    var tag: String?
    var volumeText: String = ""
    var priceText: String = ""
    var subPriceText: String = ""
    var changeText: String = ""
    var isChangePositive: Bool = false

    init() {}

    /// 构建无永续标签的现货行。
    convenience init(
        pair: String,
        tag: String? = nil,
        volumeText: String,
        priceText: String,
        subPriceText: String,
        changeText: String,
        isChangePositive: Bool
    ) {
        self.init()
        self.pair = pair
        self.tag = tag
        self.volumeText = volumeText
        self.priceText = priceText
        self.subPriceText = subPriceText
        self.changeText = changeText
        self.isChangePositive = isChangePositive
    }
}

/// 行情概况卡片 + 宏观事件标题。
final class VLHomeMarketOverviewModel: Then {
    var title: String = ""
    var cards: [VLHomeMarketOverviewCardModel] = []
    var eventTitle: String = ""

    init() {}

    convenience init(title: String, cards: [VLHomeMarketOverviewCardModel], eventTitle: String) {
        self.init()
        self.title = title
        self.cards = cards
        self.eventTitle = eventTitle
    }
}

/// 单张概况统计卡片（市值、成交额等）。
final class VLHomeMarketOverviewCardModel: Then {
    var label: String = ""
    var value: String = ""
    var changeText: String?
    var isChangePositive: Bool?
    var coinName: String?

    init() {}

    convenience init(
        label: String,
        value: String,
        changeText: String?,
        isChangePositive: Bool?,
        coinName: String?
    ) {
        self.init()
        self.label = label
        self.value = value
        self.changeText = changeText
        self.isChangePositive = isChangePositive
        self.coinName = coinName
    }
}

/// 公告列表分区模型。
final class VLHomeAnnouncementModel: Then {
    var title: String = ""
    var announcements: [VLHomeAnnouncementEntryModel] = []

    init() {}

    convenience init(title: String, announcements: [VLHomeAnnouncementEntryModel]) {
        self.init()
        self.title = title
        self.announcements = announcements
    }
}

/// 单条公告行。
final class VLHomeAnnouncementEntryModel: Then {
    var title: String = ""
    var publishedAt: String = ""

    init() {}

    convenience init(title: String, publishedAt: String) {
        self.init()
        self.title = title
        self.publishedAt = publishedAt
    }
}
