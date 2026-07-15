import Foundation

/// 自 Flutter `home_exchange_provider.dart` 移植的 mock 数据。
enum VLHomeExchangeMockData {

    /// 有序的首页交易所分区（搜索 → 公告）。
    static let items: [VLHomeExchangeListItem] = [
        .search(VLHomeSearchModel(hints: searchHints)),
        .assets(VLHomeAssetsModel(currencies: currencies)),
        .banner(VLHomeBannerModel(banners: banners)),
        .marketList(VLHomeMarketListModel(tabs: marketTabs)),
        .marketOverview(VLHomeMarketOverviewModel(
            title: "行情概况",
            cards: overviewCards,
            eventTitle: "美联储公布3月利率决议，鲍威尔出席新闻发布会"
        )),
        .announcement(VLHomeAnnouncementModel(
            title: "公告",
            announcements: announcements
        )),
    ]

    private static let searchHints: [VLHomeSearchHintModel] = [
        VLHomeSearchHintModel(text: "BTC/USDT", iconName: "bitcoinsign.circle"),
        VLHomeSearchHintModel(text: "ETH 热门", iconName: "flame"),
        VLHomeSearchHintModel(text: "搜索币种/合约", iconName: ""),
    ]

    private static let currencies: [VLHomeAssetsCurrencyModel] = [
        VLHomeAssetsCurrencyModel(
            symbol: "USDT", totalValue: "2,000", todayProfit: "$2,000",
            todayProfitRate: "100%", isProfitPositive: true,
            chartPoints: [1.0, 1.12, 1.28, 1.45, 1.55, 1.32, 1.05, 0.72, 0.48, 0.35,
                          0.58, 0.92, 1.25, 1.62, 1.88, 2.1]
        ),
        VLHomeAssetsCurrencyModel(
            symbol: "USD", totalValue: "2,000", todayProfit: "$127.12",
            todayProfitRate: "2.45%", isProfitPositive: true,
            chartPoints: [0.42, 0.48, 0.55, 0.5, 0.62, 0.7, 0.58, 0.66, 0.78, 0.72, 0.85, 0.92]
        ),
        VLHomeAssetsCurrencyModel(
            symbol: "CNY", totalValue: "14,360", todayProfit: "¥912.45",
            todayProfitRate: "2.45%", isProfitPositive: true,
            chartPoints: [0.28, 0.32, 0.38, 0.5, 0.45, 0.52, 0.6, 0.72, 0.68, 0.74, 0.8, 0.88]
        ),
        VLHomeAssetsCurrencyModel(
            symbol: "BTC", totalValue: "0.032", todayProfit: "0.0008",
            todayProfitRate: "2.45%", isProfitPositive: true,
            chartPoints: [0.35, 0.42, 0.4, 0.55, 0.62, 0.5, 0.68, 0.75, 0.7, 0.82, 0.9, 0.88]
        ),
    ]

    private static let banners: [VLHomeBannerSlideModel] = [
        VLHomeBannerSlideModel(iconName: "giftcard", title: "新人福利", subtitle: "注册即领 100 USDT 体验金"),
        VLHomeBannerSlideModel(iconName: "banknote", title: "活期理财", subtitle: "年化收益最高 8.5%，随存随取灵活方便"),
        VLHomeBannerSlideModel(iconName: "chart.line.uptrend.xyaxis", title: "合约交易赛", subtitle: "瓜分 50,000 USDT 奖池"),
        VLHomeBannerSlideModel(iconName: "bitcoinsign.circle", title: "BTC 专区", subtitle: "零手续费交易限时开启"),
        VLHomeBannerSlideModel(iconName: "flame", title: "热门新币", subtitle: "SOL / PEPE 火热上线"),
        VLHomeBannerSlideModel(iconName: "shield", title: "安全中心", subtitle: "开启双重验证保护资产"),
        VLHomeBannerSlideModel(iconName: "person.2", title: "邀请好友", subtitle: "双方各得 20 USDT 奖励"),
        VLHomeBannerSlideModel(iconName: "megaphone", title: "平台公告", subtitle: "系统维护完成，服务已恢复"),
    ]

    private static let marketTabs: [VLHomeMarketListTabModel] = [
        VLHomeMarketListTabModel(title: "自选", spotRows: [
            coin("BTCUSDT", vol: "$56.83亿", price: "67,890.1", sub: "$67,890.0", ch: "+2.45%", up: true),
            coin("ETHUSDT", vol: "$32.16亿", price: "3,456.7", sub: "$3,456.6", ch: "-1.12%", up: false),
            coin("SOLUSDT", vol: "$8.42亿", price: "178.56", sub: "$178.50", ch: "+5.67%", up: true),
            coin("DOGEUSDT", vol: "$5.21亿", price: "0.1823", sub: "$0.1822", ch: "+0.89%", up: true),
            coin("XRPUSDT", vol: "$4.08亿", price: "0.6234", sub: "$0.6230", ch: "-0.34%", up: false),
        ]),
        VLHomeMarketListTabModel(title: "热门榜", showSpotSwapToggle: true, spotRows: hotSpot, swapRows: hotSwap),
        VLHomeMarketListTabModel(title: "涨幅榜", spotRows: gainers),
        VLHomeMarketListTabModel(title: "跌幅榜", spotRows: losers),
        VLHomeMarketListTabModel(title: "新币榜", showSpotSwapToggle: true, spotRows: newSpot, swapRows: newSwap),
    ]

    private static let hotSpot: [VLHomeMarketCoinRowModel] = [
        coin("PEPEUSDT", vol: "$12.56亿", price: "0.00001234", sub: "$0.00001230", ch: "+12.56%", up: true),
        coin("WIFUSDT", vol: "$6.78亿", price: "2.3456", sub: "$2.3450", ch: "+8.90%", up: true),
        coin("BONKUSDT", vol: "$4.32亿", price: "0.00002345", sub: "$0.00002340", ch: "+6.78%", up: true),
        coin("SUIUSDT", vol: "$3.89亿", price: "1.5678", sub: "$1.5670", ch: "+4.32%", up: true),
        coin("ARBUSDT", vol: "$2.56亿", price: "0.9876", sub: "$0.9870", ch: "-2.10%", up: false),
    ]

    private static let hotSwap: [VLHomeMarketCoinRowModel] = [
        swap("BTCUSDT", vol: "$128.56亿", price: "67,912.0", sub: "$67,910.5", ch: "+2.48%", up: true),
        swap("ETHUSDT", vol: "$86.32亿", price: "3,458.9", sub: "$3,458.5", ch: "-1.05%", up: false),
        swap("SOLUSDT", vol: "$24.18亿", price: "179.12", sub: "$179.08", ch: "+5.72%", up: true),
        swap("DOGEUSDT", vol: "$9.56亿", price: "0.1828", sub: "$0.1826", ch: "+0.95%", up: true),
        swap("PEPEUSDT", vol: "$18.42亿", price: "0.00001240", sub: "$0.00001238", ch: "+12.80%", up: true),
    ]

    private static let gainers: [VLHomeMarketCoinRowModel] = [
        coin("ORDIUSDT", vol: "$3.21亿", price: "45.678", sub: "$45.670", ch: "+28.56%", up: true),
        coin("TIAUSDT", vol: "$2.89亿", price: "12.345", sub: "$12.340", ch: "+22.34%", up: true),
        coin("SEIUSDT", vol: "$2.12亿", price: "0.7890", sub: "$0.7885", ch: "+18.90%", up: true),
        coin("INJUSDT", vol: "$1.98亿", price: "28.901", sub: "$28.890", ch: "+16.78%", up: true),
        coin("FETUSDT", vol: "$1.56亿", price: "2.3456", sub: "$2.3450", ch: "+14.23%", up: true),
    ]

    private static let losers: [VLHomeMarketCoinRowModel] = [
        coin("LUNAUSDT", vol: "$0.89亿", price: "0.4567", sub: "$0.4560", ch: "-18.56%", up: false),
        coin("FTMUSDT", vol: "$1.12亿", price: "0.6789", sub: "$0.6780", ch: "-15.34%", up: false),
        coin("GALAUSDT", vol: "$0.76亿", price: "0.0345", sub: "$0.0344", ch: "-12.89%", up: false),
        coin("SANDUSDT", vol: "$0.65亿", price: "0.4123", sub: "$0.4120", ch: "-10.45%", up: false),
        coin("MANAUSDT", vol: "$0.58亿", price: "0.3890", sub: "$0.3885", ch: "-8.67%", up: false),
    ]

    private static let newSpot: [VLHomeMarketCoinRowModel] = [
        coin("STRKUSDT", vol: "$2.56亿", price: "1.2345", sub: "$1.2340", ch: "+18.90%", up: true),
        coin("PIXELUSDT", vol: "$1.89亿", price: "0.5678", sub: "$0.5670", ch: "+15.67%", up: true),
        coin("PORTALUSDT", vol: "$1.42亿", price: "2.8901", sub: "$2.8890", ch: "+11.23%", up: true),
        coin("AEVOUSDT", vol: "$1.08亿", price: "3.4567", sub: "$3.4560", ch: "+9.87%", up: true),
        coin("ENAUSDT", vol: "$0.96亿", price: "0.7890", sub: "$0.7885", ch: "+7.65%", up: true),
    ]

    private static let newSwap: [VLHomeMarketCoinRowModel] = [
        swap("STRKUSDT", vol: "$4.12亿", price: "1.2380", sub: "$1.2375", ch: "+19.12%", up: true),
        swap("PIXELUSDT", vol: "$2.56亿", price: "0.5690", sub: "$0.5685", ch: "+15.90%", up: true),
        swap("PORTALUSDT", vol: "$1.98亿", price: "2.8950", sub: "$2.8940", ch: "+11.45%", up: true),
        swap("AEVOUSDT", vol: "$1.56亿", price: "3.4600", sub: "$3.4590", ch: "+10.01%", up: true),
        swap("ENAUSDT", vol: "$1.32亿", price: "0.7910", sub: "$0.7905", ch: "+7.80%", up: true),
    ]

    private static let overviewCards: [VLHomeMarketOverviewCardModel] = [
        VLHomeMarketOverviewCardModel(label: "市值", value: "$2.26万亿", changeText: "+0.15%", isChangePositive: true, coinName: nil),
        VLHomeMarketOverviewCardModel(label: "成交额", value: "$543.65亿", changeText: "-5.67%", isChangePositive: false, coinName: nil),
        VLHomeMarketOverviewCardModel(label: "市值占比", value: "55.63%", changeText: nil, isChangePositive: nil, coinName: "Bitcoin"),
    ]

    private static let announcements: [VLHomeAnnouncementEntryModel] = [
        VLHomeAnnouncementEntryModel(
            title: "关于部分网络升级维护的通知，期间充提可能短暂暂停，请提前安排您的资产操作",
            publishedAt: "2026/07/03 22:35"
        ),
        VLHomeAnnouncementEntryModel(
            title: "OKX 将上线 RESOLV (Resolv) 现货交易及 RESOLV/USDT 现货交易，支持充值与提现",
            publishedAt: "2026/07/03 18:12"
        ),
        VLHomeAnnouncementEntryModel(
            title: "关于调整部分永续合约资金费率间隔的公告，涉及 BTC、ETH、SOL 等多个主流品种",
            publishedAt: "2026/07/02 09:48"
        ),
    ]

    /// 构建现货 coin 行辅助方法。
    private static func coin(
        _ pair: String, vol: String, price: String, sub: String, ch: String, up: Bool
    ) -> VLHomeMarketCoinRowModel {
        VLHomeMarketCoinRowModel(
            pair: pair, volumeText: vol, priceText: price,
            subPriceText: sub, changeText: ch, isChangePositive: up
        )
    }

    /// 构建永续合约行辅助方法。
    private static func swap(
        _ pair: String, vol: String, price: String, sub: String, ch: String, up: Bool
    ) -> VLHomeMarketCoinRowModel {
        VLHomeMarketCoinRowModel(
            pair: pair, tag: "永续", volumeText: vol, priceText: price,
            subPriceText: sub, changeText: ch, isChangePositive: up
        )
    }
}
