import UIKit
import SnapKit
import Then

/// Placeholder assets content shell for the 资产 tab.
final class VLAssetsView: UIView {

    /// Title label shown until real assets content is built.
    private lazy var titleLabel = lazyTitleLabel()

    /// Inject params and start first bind (placeholder: show title).
    func show() {
        backgroundColor = VLTabBarAppearance.pageBackground
        _ = titleLabel
    }
}

fileprivate extension VLAssetsView {

    /// Builds centered placeholder title for the assets tab.
    func lazyTitleLabel() -> UILabel {
        UILabel().then {
            $0.text = "资产"
            $0.textColor = VLTabBarAppearance.selected
            $0.font = .systemFont(ofSize: 20, weight: .medium)
            $0.textAlignment = .center
        }.make(self) {
            $0.center.equalToSuperview()
        }
    }
}
