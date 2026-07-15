import UIKit
import SnapKit
import Then

/// Thin assets tab root; owns `VLAssetsView` (Flutter 资产).
final class VLAssetsVC: UIViewController {

    /// Main content view owned by this page.
    private lazy var mainView = lazyMainView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = VLTabBarAppearance.pageBackground
        _ = mainView
    }
}

fileprivate extension VLAssetsVC {

    /// Build and pin `VLAssetsView` to the root view.
    func lazyMainView() -> VLAssetsView {
        VLAssetsView().then { $0.show() }.make(view) {
            $0.edges.equalToSuperview()
        }
    }
}
