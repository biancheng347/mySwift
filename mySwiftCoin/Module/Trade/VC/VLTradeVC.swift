import UIKit
import SnapKit
import Then

/// Thin trade tab root; owns `VLTradeView` (Flutter 交易).
final class VLTradeVC: UIViewController {

    /// Main content view owned by this page.
    private lazy var mainView = lazyMainView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = VLTabBarAppearance.pageBackground
        _ = mainView
    }
}

fileprivate extension VLTradeVC {

    /// Build and pin `VLTradeView` to the root view.
    func lazyMainView() -> VLTradeView {
        VLTradeView().then { $0.show() }.make(view) {
            $0.edges.equalToSuperview()
        }
    }
}
