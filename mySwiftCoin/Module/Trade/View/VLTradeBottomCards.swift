import UIKit
import SnapKit
import Then

/// 底部持仓 / 委托 / 资产卡片构建（对齐 OKX App 信息密度）。
enum VLTradeBottomCards {

    /// 合约持仓卡。
    static func positionCard(_ model: VLTradePositionModel) -> UIView {
        let card = surfaceCard()
        let side = model.isLong ? "多" : "空"
        let sideColor = model.isLong ? VLTradeAppearance.up : VLTradeAppearance.down
        let title = UILabel().then {
            $0.text = "\(model.symbol) 永续"
            $0.textColor = VLTradeAppearance.textPrimary
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
        }
        let badge = UILabel().then {
            $0.text = " \(side) "
            $0.textColor = sideColor
            $0.font = .systemFont(ofSize: 11, weight: .bold)
            $0.backgroundColor = sideColor.withAlphaComponent(0.15)
            $0.layer.cornerRadius = 3
            $0.clipsToBounds = true
        }
        let mode = UILabel().then {
            $0.text = "\(model.isCrossMargin ? "全仓" : "逐仓") \(model.leverage)"
            $0.textColor = VLTradeAppearance.textSecondary
            $0.font = .systemFont(ofSize: 11, weight: .medium)
        }
        let pnl = UILabel().then {
            $0.text = "收益 \(model.pnl)  (\(model.pnlRatio))"
            $0.textColor = model.isProfit ? VLTradeAppearance.up : VLTradeAppearance.down
            $0.font = .systemFont(ofSize: 13, weight: .semibold)
        }
        let grid = gridView([
            ("持仓量", "\(model.size) \(model.sizeUnit)"),
            ("开仓均价", model.avgPrice),
            ("标记价格", model.markPrice),
            ("预估强平价", model.liqPrice),
            ("保证金", model.margin),
            ("可平", model.size)
        ])
        let actions = actionRow(["止盈止损", "市价全平", "平仓"])
        [title, badge, mode, pnl, grid, actions].forEach { card.addSubview($0) }
        title.snp.makeConstraints { $0.top.leading.equalToSuperview().inset(12.rpx) }
        badge.snp.makeConstraints {
            $0.centerY.equalTo(title)
            $0.leading.equalTo(title.snp.trailing).offset(6.rpx)
        }
        mode.snp.makeConstraints {
            $0.centerY.equalTo(title)
            $0.leading.equalTo(badge.snp.trailing).offset(6.rpx)
        }
        pnl.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8.rpx)
            $0.leading.trailing.equalToSuperview().inset(12.rpx)
        }
        grid.snp.makeConstraints {
            $0.top.equalTo(pnl.snp.bottom).offset(10.rpx)
            $0.leading.trailing.equalToSuperview().inset(12.rpx)
        }
        actions.snp.makeConstraints {
            $0.top.equalTo(grid.snp.bottom).offset(12.rpx)
            $0.leading.trailing.equalToSuperview().inset(12.rpx)
            $0.height.equalTo(30.rpx)
            $0.bottom.equalToSuperview().offset(-12.rpx)
        }
        return card
    }

    /// 当前委托卡。
    static func orderCard(_ model: VLTradeOpenOrderModel) -> UIView {
        let card = surfaceCard()
        let sideColor = model.side == .buy ? VLTradeAppearance.up : VLTradeAppearance.down
        let title = UILabel().then {
            $0.text = "\(model.orderType)\(model.sideTitle)  \(model.symbol)\(model.isFutures ? " 永续" : "")"
            $0.textColor = sideColor
            $0.font = .systemFont(ofSize: 13, weight: .semibold)
        }
        let time = UILabel().then {
            $0.text = model.timeText
            $0.textColor = VLTradeAppearance.textTertiary
            $0.font = .systemFont(ofSize: 11, weight: .regular)
        }
        let grid = gridView([
            ("委托价格", model.price),
            ("委托数量", model.amount),
            ("已成交", model.filled),
            ("未成交", residual(model))
        ])
        let cancel = UIButton(type: .system).then {
            $0.setTitle("撤单", for: .normal)
            $0.setTitleColor(VLTradeAppearance.textPrimary, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
            $0.backgroundColor = VLTradeAppearance.elevated
            $0.layer.cornerRadius = VLTradeLayout.buttonCornerRadius
        }
        [title, time, grid, cancel].forEach { card.addSubview($0) }
        title.snp.makeConstraints { $0.top.leading.equalToSuperview().inset(12.rpx) }
        time.snp.makeConstraints {
            $0.centerY.equalTo(title)
            $0.trailing.equalToSuperview().offset(-12.rpx)
        }
        grid.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8.rpx)
            $0.leading.equalToSuperview().inset(12.rpx)
            $0.trailing.equalTo(cancel.snp.leading).offset(-10.rpx)
            $0.bottom.equalToSuperview().offset(-12.rpx)
        }
        cancel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12.rpx)
            $0.bottom.equalToSuperview().offset(-12.rpx)
            $0.width.equalTo(56.rpx)
            $0.height.equalTo(28.rpx)
        }
        return card
    }

    /// 现货资产卡。
    static func assetCard(_ model: VLTradeAssetModel) -> UIView {
        let card = surfaceCard()
        let coin = UILabel().then {
            $0.text = model.coin
            $0.textColor = VLTradeAppearance.textPrimary
            $0.font = .systemFont(ofSize: 15, weight: .semibold)
        }
        let equity = UILabel().then {
            $0.text = "≈ \(model.equityUSDT) USDT"
            $0.textColor = VLTradeAppearance.textSecondary
            $0.font = .systemFont(ofSize: 12, weight: .regular)
            $0.textAlignment = .right
        }
        let grid = gridView([("可用", model.available), ("冻结", model.frozen)])
        [coin, equity, grid].forEach { card.addSubview($0) }
        coin.snp.makeConstraints { $0.top.leading.equalToSuperview().inset(12.rpx) }
        equity.snp.makeConstraints {
            $0.centerY.equalTo(coin)
            $0.trailing.equalToSuperview().offset(-12.rpx)
        }
        grid.snp.makeConstraints {
            $0.top.equalTo(coin.snp.bottom).offset(10.rpx)
            $0.leading.trailing.equalToSuperview().inset(12.rpx)
            $0.bottom.equalToSuperview().offset(-12.rpx)
        }
        return card
    }
}

fileprivate extension VLTradeBottomCards {

    /// 卡片底。
    static func surfaceCard() -> UIView {
        UIView().then {
            $0.backgroundColor = VLTradeAppearance.surface
            $0.layer.cornerRadius = VLTradeLayout.buttonCornerRadius
        }
    }

    /// 两列 KV 网格。
    static func gridView(_ pairs: [(String, String)]) -> UIView {
        let grid = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 6.rpx
        }
        stride(from: 0, to: pairs.count, by: 2).forEach { index in
            let left = pairs[index]
            let right = index + 1 < pairs.count ? pairs[index + 1] : nil
            let row = UIStackView().then {
                $0.axis = .horizontal
                $0.distribution = .fillEqually
                $0.spacing = 8.rpx
            }
            row.addArrangedSubview(kv(left.0, left.1))
            row.addArrangedSubview(right.map { kv($0.0, $0.1) } ?? UIView())
            grid.addArrangedSubview(row)
        }
        return grid
    }

    /// 单个 KV。
    static func kv(_ key: String, _ value: String) -> UIView {
        let box = UIView()
        let k = UILabel().then {
            $0.text = key
            $0.textColor = VLTradeAppearance.textTertiary
            $0.font = .systemFont(ofSize: 11, weight: .regular)
        }
        let v = UILabel().then {
            $0.text = value
            $0.textColor = VLTradeAppearance.textPrimary
            $0.font = .systemFont(ofSize: 12, weight: .medium)
        }
        box.addSubview(k)
        box.addSubview(v)
        k.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
        v.snp.makeConstraints {
            $0.top.equalTo(k.snp.bottom).offset(2)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        return box
    }

    /// 操作按钮行。
    static func actionRow(_ titles: [String]) -> UIStackView {
        let buttons = titles.map { title in
            UIButton(type: .system).then {
                $0.setTitle(title, for: .normal)
                $0.setTitleColor(VLTradeAppearance.textPrimary, for: .normal)
                $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
                $0.backgroundColor = VLTradeAppearance.elevated
                $0.layer.cornerRadius = VLTradeLayout.buttonCornerRadius
            }
        }
        return UIStackView(arrangedSubviews: buttons).then {
            $0.axis = .horizontal
            $0.spacing = 8.rpx
            $0.distribution = .fillEqually
        }
    }

    /// 未成交量。
    static func residual(_ model: VLTradeOpenOrderModel) -> String {
        let total = Double(model.amount) ?? 0
        let filled = Double(model.filled) ?? 0
        let left = max(0, total - filled)
        return model.isFutures ? String(format: "%.0f", left) : String(format: "%.4f", left)
    }
}
