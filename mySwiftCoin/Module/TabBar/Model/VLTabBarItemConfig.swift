import Foundation

/// 底部 Tab 元数据：首页 / 交易 / 资产（简洁线框 SF Symbol）。
struct VLTabBarItemConfig: Equatable {
    /// Tab 标题。
    let title: String
    /// 零基索引。
    let index: Int
    /// 未选中 SF Symbol（线框）。
    let systemImageName: String
    /// 选中 SF Symbol（同线框，靠 tint 区分）。
    let selectedSystemImageName: String

    /// Tab 顺序与文案唯一来源。
    static let defaultTabs: [VLTabBarItemConfig] = [
        VLTabBarItemConfig(
            title: "首页",
            index: 0,
            systemImageName: "house",
            selectedSystemImageName: "house"
        ),
        VLTabBarItemConfig(
            title: "交易",
            index: 1,
            systemImageName: "arrow.left.arrow.right",
            selectedSystemImageName: "arrow.left.arrow.right"
        ),
        VLTabBarItemConfig(
            title: "资产",
            index: 2,
            systemImageName: "wallet.pass",
            selectedSystemImageName: "wallet.pass"
        ),
    ]
}
