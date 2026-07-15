import UIKit
import SnapKit
import Then

/// 顶部分段：OKX 风格大字 Tab（交易所 | Web3），无胶囊底。
final class VLHomeNavView: UIView {

    /// 用户点击分段时触发（0 = 交易所，1 = Web3）。
    var onTabSelected: ((Int) -> Void)?

    private lazy var exchangeButton = lazySegmentButton(title: "交易所", tag: 0)
    private lazy var web3Button = lazySegmentButton(title: "Web3", tag: 1)
    private lazy var stack = lazyStack()
    private lazy var indicator = lazyIndicator()

    /// 构建布局并选中默认 Tab。
    func show(selectedIndex: Int = 0) {
        backgroundColor = VLHomeAppearance.pageBackground
        _ = stack
        _ = indicator
        updateSelection(selectedIndex)
    }

    /// 高亮当前选中的大字 Tab，并移动底部指示条居中对齐。
    func updateSelection(_ index: Int) {
        [exchangeButton, web3Button].enumerated().forEach { idx, button in
            let selected = idx == index
            button.setTitleColor(
                selected ? VLHomeAppearance.textPrimary : VLHomeAppearance.textSecondary,
                for: .normal
            )
            button.titleLabel?.font = .systemFont(
                ofSize: selected ? 22 : 18,
                weight: selected ? .bold : .medium
            )
        }
        layoutIfNeeded()
        let target = index == 0 ? exchangeButton : web3Button
        indicator.snp.remakeConstraints {
            $0.top.equalTo(stack.snp.bottom).offset(4.rpx)
            $0.centerX.equalTo(target)
            $0.width.equalTo(20.rpx)
            $0.height.equalTo(3.rpx)
        }
        UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() }
    }
}

fileprivate extension VLHomeNavView {

    /// 水平大字 Tab 行（水平居中）。
    func lazyStack() -> UIStackView {
        UIStackView(arrangedSubviews: [exchangeButton, web3Button]).then {
            $0.axis = .horizontal
            $0.spacing = 28.rpx
            $0.alignment = .center
        }.make(self) {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-2.rpx)
            $0.height.equalTo(36.rpx)
        }
    }

    /// 选中 Tab 下方短指示条。
    func lazyIndicator() -> UIView {
        UIView().then {
            $0.backgroundColor = VLHomeAppearance.textPrimary
            $0.layer.cornerRadius = 1.5.rpx
        }.make(self) {
            $0.top.equalTo(stack.snp.bottom).offset(4.rpx)
            $0.centerX.equalTo(exchangeButton)
            $0.width.equalTo(20.rpx)
            $0.height.equalTo(3.rpx)
        }
    }

    /// 创建单个可点击的大字分段。
    func lazySegmentButton(title: String, tag: Int) -> UIButton {
        UIButton(type: .system).then {
            $0.tag = tag
            $0.setTitle(title, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            $0.contentEdgeInsets = UIEdgeInsets(top: 4.rpx, left: 0, bottom: 4.rpx, right: 0)
            $0.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        }
    }

    /// 将芯片点击路由到回调。
    @objc func tabTapped(_ sender: UIButton) {
        onTabSelected?(sender.tag)
    }
}
