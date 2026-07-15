import UIKit
import SnapKit
import Then

/// 轻量首页 Tab 根 VC；持有 `VLHomeView`（Flutter 首页）。
final class VLHomeVC: UIViewController {

    /// 本页持有的主内容视图。
    private lazy var mainView = lazyMainView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = VLHomeAppearance.pageBackground
        _ = mainView
    }
}

fileprivate extension VLHomeVC {

    /// 构建并将 `VLHomeView` 钉在根视图上。
    func lazyMainView() -> VLHomeView {
        VLHomeView()
            .then {
                $0.show()
            }.make(view) {
                $0.edges.equalToSuperview()
        }
    }
}
