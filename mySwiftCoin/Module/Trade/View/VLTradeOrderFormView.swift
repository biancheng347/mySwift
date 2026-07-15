import UIKit
import SnapKit
import Then

/// OKX 风格左侧下单区：买/卖、全仓/逐仓、限价、数量、CTA。
final class VLTradeOrderFormView: UIView {

    /// 侧切换回调。
    var onSelectSide: ((VLTradeSide) -> Void)?
    /// 全仓/逐仓回调。
    var onSelectMarginMode: ((Bool) -> Void)?
    /// 提交回调。
    var onSubmit: (() -> Void)?

    private lazy var buyButton = lazySideButton(title: "买入", tag: 0)
    private lazy var sellButton = lazySideButton(title: "卖出", tag: 1)
    private lazy var sideStack = lazySideStack()
    private lazy var crossButton = lazyMarginButton(title: "全仓", isCross: true)
    private lazy var isolatedButton = lazyMarginButton(title: "逐仓", isCross: false)
    private lazy var leverageButton = lazyLeverageButton()
    private lazy var marginStack = lazyMarginStack()
    private lazy var orderTypeLabel = lazyOrderTypeLabel()
    private lazy var priceField = lazyField(placeholder: "价格 (USDT)")
    private lazy var amountField = lazyField(placeholder: "数量")
    private lazy var percentStack = lazyPercentStack()
    private lazy var availLabel = lazyAvailLabel()
    private lazy var submitButton = lazySubmitButton()

    private var isFutures = false

    /// 搭建表单控件。
    func show() {
        backgroundColor = VLTradeAppearance.pageBackground
        _ = sideStack.make(self) {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(34.rpx)
        }
        _ = marginStack.make(self) {
            $0.top.equalTo(sideStack.snp.bottom).offset(0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        _ = orderTypeLabel.make(self) {
            $0.top.equalTo(marginStack.snp.bottom).offset(8.rpx)
            $0.leading.trailing.equalToSuperview()
        }
        _ = priceField.make(self) {
            $0.top.equalTo(orderTypeLabel.snp.bottom).offset(8.rpx)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40.rpx)
        }
        _ = amountField.make(self) {
            $0.top.equalTo(priceField.snp.bottom).offset(8.rpx)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40.rpx)
        }
        _ = percentStack.make(self) {
            $0.top.equalTo(amountField.snp.bottom).offset(8.rpx)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(28.rpx)
        }
        _ = availLabel.make(self) {
            $0.top.equalTo(percentStack.snp.bottom).offset(8.rpx)
            $0.leading.trailing.equalToSuperview()
        }
        _ = submitButton.make(self) {
            $0.top.equalTo(availLabel.snp.bottom).offset(12.rpx)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44.rpx)
            $0.bottom.lessThanOrEqualToSuperview()
        }
        apply(form: VLTradeOrderFormModel(), isFutures: false, baseAsset: "BTC")
    }

    /// 同步买卖侧 / 合约保证金模式 / 价格。
    func apply(form: VLTradeOrderFormModel, isFutures: Bool, baseAsset: String = "BTC") {
        self.isFutures = isFutures
        marginStack.isHidden = !isFutures
        marginStack.snp.updateConstraints {
            $0.top.equalTo(sideStack.snp.bottom).offset(isFutures ? 10.rpx : 0)
            $0.height.equalTo(isFutures ? 28.rpx : 0)
        }
        let isBuy = form.side == .buy
        buyButton.setTitle(isFutures ? "开多" : "买入", for: .normal)
        sellButton.setTitle(isFutures ? "开空" : "卖出", for: .normal)
        styleSide(button: buyButton, selected: isBuy, active: VLTradeAppearance.up)
        styleSide(button: sellButton, selected: !isBuy, active: VLTradeAppearance.down)
        styleMargin(button: crossButton, selected: form.isCrossMargin)
        styleMargin(button: isolatedButton, selected: !form.isCrossMargin)
        leverageButton.setTitle("\(form.leverage) ▾", for: .normal)
        submitButton.backgroundColor = isBuy ? VLTradeAppearance.up : VLTradeAppearance.down
        if isFutures {
            submitButton.setTitle(isBuy ? "开多 \(baseAsset)" : "开空 \(baseAsset)", for: .normal)
        } else {
            submitButton.setTitle(isBuy ? "买入 \(baseAsset)" : "卖出 \(baseAsset)", for: .normal)
        }
        amountField.attributedPlaceholder = NSAttributedString(
            string: "数量 (\(baseAsset))",
            attributes: [.foregroundColor: VLTradeAppearance.textTertiary]
        )
        if priceField.text?.isEmpty != false {
            priceField.text = form.price
        }
    }
}

fileprivate extension VLTradeOrderFormView {

    /// 买卖分段。
    func lazySideStack() -> UIStackView {
        UIStackView(arrangedSubviews: [buyButton, sellButton]).then {
            $0.axis = .horizontal
            $0.spacing = 8.rpx
            $0.distribution = .fillEqually
        }
    }

    /// 买入/卖出圆角钮。
    func lazySideButton(title: String, tag: Int) -> UIButton {
        UIButton(type: .system).then {
            $0.setTitle(title, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.layer.cornerRadius = VLTradeLayout.sideButtonCornerRadius
            $0.clipsToBounds = true
            $0.tag = tag
            $0.addTarget(self, action: #selector(sideTapped(_:)), for: .touchUpInside)
        }
    }

    /// 全仓 / 逐仓圆角钮（对齐 OKX App）。
    func lazyMarginButton(title: String, isCross: Bool) -> UIButton {
        UIButton(type: .system).then {
            $0.setTitle(title, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
            $0.layer.cornerRadius = VLTradeLayout.buttonCornerRadius
            $0.clipsToBounds = true
            $0.tag = isCross ? 1 : 0
            $0.addTarget(self, action: #selector(marginTapped(_:)), for: .touchUpInside)
        }
    }

    /// 杠杆倍数圆角钮。
    func lazyLeverageButton() -> UIButton {
        UIButton(type: .system).then {
            $0.setTitle("10x ▾", for: .normal)
            $0.setTitleColor(VLTradeAppearance.textPrimary, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
            $0.backgroundColor = VLTradeAppearance.elevated
            $0.layer.cornerRadius = VLTradeLayout.buttonCornerRadius
            $0.clipsToBounds = true
            $0.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        }
    }

    /// 全仓 | 逐仓 | 杠杆 一行。
    func lazyMarginStack() -> UIStackView {
        UIStackView(arrangedSubviews: [crossButton, isolatedButton, leverageButton]).then {
            $0.axis = .horizontal
            $0.spacing = 6.rpx
            $0.distribution = .fillEqually
            $0.isHidden = true
            $0.clipsToBounds = true
        }
    }

    /// 限价下单类型。
    func lazyOrderTypeLabel() -> UILabel {
        UILabel().then {
            $0.text = "限价 ▾"
            $0.textColor = VLTradeAppearance.textPrimary
            $0.font = .systemFont(ofSize: 13, weight: .medium)
        }
    }

    /// 价格/数量输入框。
    func lazyField(placeholder: String) -> UITextField {
        UITextField().then {
            $0.placeholder = placeholder
            $0.textColor = VLTradeAppearance.textPrimary
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.backgroundColor = VLTradeAppearance.elevated
            $0.layer.cornerRadius = VLTradeLayout.buttonCornerRadius
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
            $0.leftViewMode = .always
            $0.keyboardType = .decimalPad
            $0.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: VLTradeAppearance.textTertiary]
            )
        }
    }

    /// 25%/50%/75%/100% 快捷量。
    func lazyPercentStack() -> UIStackView {
        let titles = ["25%", "50%", "75%", "100%"]
        let buttons = titles.map { title in
            UIButton(type: .system).then {
                $0.setTitle(title, for: .normal)
                $0.setTitleColor(VLTradeAppearance.textSecondary, for: .normal)
                $0.titleLabel?.font = .systemFont(ofSize: 11, weight: .medium)
                $0.backgroundColor = VLTradeAppearance.elevated
                $0.layer.cornerRadius = VLTradeLayout.buttonCornerRadius
            }
        }
        return UIStackView(arrangedSubviews: buttons).then {
            $0.axis = .horizontal
            $0.spacing = 6.rpx
            $0.distribution = .fillEqually
        }
    }

    /// 可用余额占位。
    func lazyAvailLabel() -> UILabel {
        UILabel().then {
            $0.text = "可用  -- USDT"
            $0.textColor = VLTradeAppearance.textTertiary
            $0.font = .systemFont(ofSize: 11, weight: .regular)
        }
    }

    /// 主 CTA。
    func lazySubmitButton() -> UIButton {
        UIButton(type: .system).then {
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.layer.cornerRadius = VLTradeLayout.buttonCornerRadius
            $0.clipsToBounds = true
            $0.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        }
    }

    /// 选中/未选中侧钮样式。
    func styleSide(button: UIButton, selected: Bool, active: UIColor) {
        button.backgroundColor = selected ? active : VLTradeAppearance.elevated
        button.setTitleColor(selected ? .white : VLTradeAppearance.textSecondary, for: .normal)
    }

    /// 全仓/逐仓选中样式。
    func styleMargin(button: UIButton, selected: Bool) {
        button.backgroundColor = selected ? VLTradeAppearance.elevated : .clear
        button.setTitleColor(
            selected ? VLTradeAppearance.textPrimary : VLTradeAppearance.textSecondary,
            for: .normal
        )
        button.layer.borderWidth = selected ? 0 : 1
        button.layer.borderColor = VLTradeAppearance.elevated.cgColor
    }

    /// 侧按钮点击。
    @objc func sideTapped(_ sender: UIButton) {
        onSelectSide?(sender.tag == 0 ? .buy : .sell)
    }

    /// 全仓/逐仓点击。
    @objc func marginTapped(_ sender: UIButton) {
        onSelectMarginMode?(sender.tag == 1)
    }

    /// 提交点击。
    @objc func submitTapped() {
        onSubmit?()
    }
}
