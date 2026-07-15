import UIKit
import SnapKit
import Then

/// Web3 Tab 第一期占位内容。
final class VLHomeWeb3View: UIView {

    private lazy var label = lazyLabel()

    /// 显示 Web3 占位文案。
    func show() {
        backgroundColor = VLHomeAppearance.pageBackground
        _ = label
    }
}

fileprivate extension VLHomeWeb3View {

    /// 居中的占位标签。
    func lazyLabel() -> UILabel {
        UILabel().then {
            $0.text = "Web3 即将上线"
            $0.textColor = VLHomeAppearance.textSecondary
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textAlignment = .center
        }.make(self) {
            $0.center.equalToSuperview()
        }
    }
}
