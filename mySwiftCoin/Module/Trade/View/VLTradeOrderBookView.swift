import UIKit
import SnapKit
import Then

/// OKX 交易页竖向盘口：上卖下买，中间最新价。
final class VLTradeOrderBookView: UIView {

    private lazy var headerLabel = lazyHeaderLabel()
    private lazy var askStack = lazyStack()
    private lazy var midPriceLabel = lazyMidPriceLabel()
    private lazy var bidStack = lazyStack()

    private var lastMidColor: UIColor = VLTradeAppearance.up

    /// 搭建竖向盘口。
    func show() {
        backgroundColor = VLTradeAppearance.pageBackground
        _ = headerLabel
        _ = askStack
        _ = midPriceLabel
        _ = bidStack
        layoutStacks()
    }

    /// 刷新买卖盘与中间价；合约显示张。
    func apply(
        book: VLTradeOrderBookModel,
        lastPrice: String? = nil,
        isUp: Bool = true,
        isFutures: Bool = false
    ) {
        headerLabel.text = isFutures ? "价格        数量(张)" : "价格        数量"
        let askShow = Array(book.asks.prefix(VLTradeLayout.orderBookLevels).reversed())
        let bidShow = Array(book.bids.prefix(VLTradeLayout.orderBookLevels))
        reload(stack: askStack, levels: askShow, isAsk: true)
        reload(stack: bidStack, levels: bidShow, isAsk: false)
        if let lastPrice, !lastPrice.isEmpty {
            midPriceLabel.text = lastPrice
            lastMidColor = isUp ? VLTradeAppearance.up : VLTradeAppearance.down
            midPriceLabel.textColor = lastMidColor
        } else if let bestAsk = book.asks.first?.price {
            midPriceLabel.text = bestAsk
            midPriceLabel.textColor = lastMidColor
        }
    }
}

fileprivate extension VLTradeOrderBookView {

    /// 列头。
    func lazyHeaderLabel() -> UILabel {
        UILabel().then {
            $0.text = "价格        数量"
            $0.textColor = VLTradeAppearance.textTertiary
            $0.font = .systemFont(ofSize: 10, weight: .regular)
        }.make(self) {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }

    /// 档位竖栈（不设行高，由 fillEqually 填满固定总高，避免与 spacing 冲突）。
    func lazyStack() -> UIStackView {
        UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 1
            $0.distribution = .fillEqually
            $0.alignment = .fill
        }
    }

    /// 中间最新价。
    func lazyMidPriceLabel() -> UILabel {
        UILabel().then {
            $0.text = "--"
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = VLTradeAppearance.up
        }
    }

    /// 买卖盘固定总高度（含行间距）。
    var sideStackHeight: CGFloat {
        let levels = CGFloat(VLTradeLayout.orderBookLevels)
        let spacing = CGFloat(max(0, VLTradeLayout.orderBookLevels - 1))
        return levels * VLTradeLayout.orderBookRowHeight + spacing
    }

    /// 约束卖盘 / 中价 / 买盘。
    func layoutStacks() {
        askStack.make(self) {
            $0.top.equalTo(headerLabel.snp.bottom).offset(4.rpx)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(sideStackHeight)
        }
        midPriceLabel.make(self) {
            $0.top.equalTo(askStack.snp.bottom).offset(6.rpx)
            $0.leading.trailing.equalToSuperview()
        }
        bidStack.make(self) {
            $0.top.equalTo(midPriceLabel.snp.bottom).offset(6.rpx)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(sideStackHeight)
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }

    /// 重建一侧档位。
    func reload(stack: UIStackView, levels: [VLTradeOrderBookLevelModel], isAsk: Bool) {
        stack.arrangedSubviews.forEach {
            stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        levels.forEach { stack.addArrangedSubview(makeRow(level: $0, isAsk: isAsk)) }
    }

    /// 单档：深度条 + 价/量（高度交给 Stack fillEqually）。
    func makeRow(level: VLTradeOrderBookLevelModel, isAsk: Bool) -> UIView {
        let row = UIView()
        row.setContentHuggingPriority(.defaultLow, for: .vertical)
        row.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        let depth = UIView().then {
            $0.backgroundColor = isAsk ? VLTradeAppearance.askDepth : VLTradeAppearance.bidDepth
        }.make(row) {
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(max(0.05, min(1, Double(level.depthRatio))))
        }
        _ = depth

        let price = UILabel().then {
            $0.text = level.price
            $0.textColor = isAsk ? VLTradeAppearance.down : VLTradeAppearance.up
            $0.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        }.make(row) {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        _ = price

        let amount = UILabel().then {
            $0.text = level.amount
            $0.textColor = VLTradeAppearance.textSecondary
            $0.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
            $0.textAlignment = .right
        }.make(row) {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(price.snp.trailing).offset(4)
        }
        _ = amount
        return row
    }
}
