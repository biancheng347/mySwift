import UIKit

/// App 根 `UITabBarController`：首页 / 交易 / 资产。
final class VLMainTabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        applyAppearance()
        viewControllers = Self.makeChildViewControllers()
        selectedIndex = 0
    }

    /// 合法且不同于当前索引时切换 Tab。
    func selectTab(_ index: Int) {
        guard let count = viewControllers?.count,
              (0..<count).contains(index),
              index != selectedIndex else { return }
        selectedIndex = index
    }
}

// MARK: - Assembly

fileprivate extension VLMainTabBarVC {

    /// 按配置组装三个根 VC。
    static func makeChildViewControllers() -> [UIViewController] {
        VLTabBarItemConfig.defaultTabs.map { config in
            let vc: UIViewController
            switch config.index {
            case 0: vc = VLHomeVC()
            case 1: vc = VLTradeVC()
            default: vc = VLAssetsVC()
            }
            vc.tabBarItem = makeTabBarItem(for: config)
            return vc
        }
    }

    /// 创建模板渲染的简洁 Tab Item（无 fill/多层特效）。
    static func makeTabBarItem(for config: VLTabBarItemConfig) -> UITabBarItem {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: config.systemImageName, withConfiguration: symbolConfig)?
            .withRenderingMode(.alwaysTemplate)
        let selectedImage = UIImage(systemName: config.selectedSystemImageName, withConfiguration: symbolConfig)?
            .withRenderingMode(.alwaysTemplate) ?? image
        assert(image != nil, "Missing SF Symbol: \(config.systemImageName)")
        let item = UITabBarItem(title: config.title, image: image, selectedImage: selectedImage)
        item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return item
    }

    /// 不透明深色底 + 明确 tint，去掉选中指示动画痕迹。
    func applyAppearance() {
        tabBar.isTranslucent = false
        tabBar.barTintColor = VLTabBarAppearance.barBackground
        tabBar.tintColor = VLTabBarAppearance.selected
        tabBar.unselectedItemTintColor = VLTabBarAppearance.unselected
        tabBar.backgroundColor = VLTabBarAppearance.barBackground
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.selectionIndicatorImage = UIImage()

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = VLTabBarAppearance.barBackground
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.selectionIndicatorTintColor = .clear
        appearance.selectionIndicatorImage = UIImage()

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = VLTabBarAppearance.unselected
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: VLTabBarAppearance.unselected,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
        ]
        itemAppearance.selected.iconColor = VLTabBarAppearance.selected
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: VLTabBarAppearance.selected,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
        ]
        // 禁用选中态额外特效底色，避免水波纹/胶囊残留感。
        itemAppearance.normal.badgeBackgroundColor = .clear
        itemAppearance.selected.badgeBackgroundColor = .clear

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
