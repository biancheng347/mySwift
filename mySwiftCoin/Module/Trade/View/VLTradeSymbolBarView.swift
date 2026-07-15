import UIKit
import SnapKit
import Then

/// OKX 交易对栏：BTC/ETH 切换 + 涨跌 + 最新价。
final class VLTradeSymbolBarView: UIView {

    /// 交易对切换回调。
    var onSelectSymbol: ((String) -> Void)?

    private lazy var pairStack = lazyPairStack()
    private lazy var changeLabel = lazyChangeLabel()
    private lazy var priceLabel = lazyPriceLabel()
    private var pairButtons: [UIButton] = []

    /// 初始化布局。
    func show() {
        backgroundColor = VLTradeAppearance.pageBackground
        _ = pairStack
        _ = changeLabel
        _ = priceLabel
        applySelectedSymbol(VLTradePair.btcUSDT)
    }

    /// 用 ticker 刷新。
    func apply(ticker: VLTradeTickerModel, isFutures: Bool) {
        applySelectedSymbol(ticker.symbol)
        priceLabel.text = ticker.lastPrice
        priceLabel.textColor = ticker.isUp ? VLTradeAppearance.up : VLTradeAppearance.down
        let suffix = isFutures ? " 永续" : ""
        changeLabel.text = "\(ticker.changePercent)\(suffix)"
        changeLabel.textColor = ticker.isUp ? VLTradeAppearance.up : VLTradeAppearance.down
    }

    /// 同步选中币对 chip。
    func applySelectedSymbol(_ symbol: String) {
        for (index, button) in pairButtons.enumerated() {
            let target = VLTradePair.tradableSymbols[index]
            let selected = target == symbol
            button.backgroundColor = selected ? VLTradeAppearance.elevated : .clear
            button.setTitleColor(
                selected ? VLTradeAppearance.textPrimary : VLTradeAppearance.textSecondary,
                for: .normal
            )
            button.layer.borderWidth = selected ? 0 : 1
        }
    }
}

fileprivate extension VLTradeSymbolBarView {

    /// BTC / ETH 圆角切换。
    func lazyPairStack() -> UIStackView {
        pairButtons = VLTradePair.tradableSymbols.enumerated().map { index, symbol in
            let base = String(symbol.split(separator: "/").first ?? Substring(symbol))
            return UIButton(type: .system).then {
                $0.setTitle(base, for: .normal)
                $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
                $0.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
                $0.layer.cornerRadius = VLTradeLayout.buttonCornerRadius
                $0.layer.borderColor = VLTradeAppearance.elevated.cgColor
                $0.tag = index
                $0.addTarget(self, action: #selector(pairTapped(_:)), for: .touchUpInside)
            }
        }
        return UIStackView(arrangedSubviews: pairButtons).then {
            $0.axis = .horizontal
            $0.spacing = 8.rpx
        }.make(self) {
            $0.leading.equalToSuperview().offset(VLTradeLayout.horizontalInset)
            $0.centerY.equalToSuperview()
        }
    }

    /// 涨跌幅。
    func lazyChangeLabel() -> UILabel {
        UILabel().then {
            $0.text = "--"
            $0.font = .systemFont(ofSize: 12, weight: .medium)
        }.make(self) {
            $0.leading.equalTo(pairStack.snp.trailing).offset(10.rpx)
            $0.centerY.equalToSuperview()
        }
    }

    /// 最新价（右侧）。
    func lazyPriceLabel() -> UILabel {
        UILabel().then {
            $0.text = "--"
            $0.font = .systemFont(ofSize: 15, weight: .semibold)
            $0.textAlignment = .right
        }.make(self) {
            $0.trailing.equalToSuperview().offset(-VLTradeLayout.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(changeLabel.snp.trailing).offset(8.rpx)
        }
    }

    /// 币对点击。
    @objc func pairTapped(_ sender: UIButton) {
        guard sender.tag >= 0, sender.tag < VLTradePair.tradableSymbols.count else { return }
        onSelectSymbol?(VLTradePair.tradableSymbols[sender.tag])
    }
}
