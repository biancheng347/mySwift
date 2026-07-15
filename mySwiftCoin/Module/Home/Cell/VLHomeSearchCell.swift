import UIKit
import SnapKit
import Then

/// 首页搜索栏：左侧固定搜索图标，右侧提示（icon+文字 / 纯文字）自下而上轮播。
final class VLHomeSearchCell: BaseCVCell {

    private var hints: [VLHomeSearchHintModel] = []
    private var currentIndex = 0
    private var scrollTimer: DispatchSourceTimer?

    private lazy var container = lazyContainer()
    private lazy var searchIconView = lazySearchIconView()
    private lazy var hintClipView = lazyHintClipView()
    private lazy var currentRow = lazyCurrentRow()
    private lazy var nextRow = lazyNextRow()

    /// 配置提示列表并启动自下而上轮播。
    override func cell(model: ItemTypeProtocol) {
        guard let item = model as? ItemTypeModel<VLHomeSearchModel> else { return }
        _ = searchIconView
        _ = nextRow
        hints = item.data.hints
        currentIndex = 0
        applyHint(at: 0, animated: false)
        startAutoScrollIfNeeded()
    }

    /// 离开复用池时停止轮播。
    override func prepareForReuse() {
        super.prepareForReuse()
        stopAutoScroll()
    }

    /// 移出窗口时暂停；可见时恢复。
    override func didMoveToWindow() {
        super.didMoveToWindow()
        window == nil ? stopAutoScroll() : startAutoScrollIfNeeded()
    }
}

fileprivate extension VLHomeSearchCell {

    /// 圆角搜索框背景。
    func lazyContainer() -> UIView {
        UIView().then {
            $0.backgroundColor = VLHomeAppearance.surface
            $0.layer.cornerRadius = 20.rpx
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(searchTapped))
            )
        }.make(contentView) {
            $0.leading.trailing.equalToSuperview().inset(VLHomeLayout.horizontalInset)
            $0.top.bottom.equalToSuperview().inset(6.rpx)
        }
    }

    /// 左侧固定搜索图标（不随 hint 切换）。
    func lazySearchIconView() -> UIImageView {
        UIImageView().then {
            $0.tintColor = VLHomeAppearance.textSecondary
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(systemName: VLHomeSearchHintDisplay.leadingSearchIconName)
        }.make(container) {
            $0.leading.equalToSuperview().offset(12.rpx)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(18.rpx)
        }
    }

    /// 裁剪右侧轮播可视区域。
    func lazyHintClipView() -> UIView {
        UIView().then {
            $0.clipsToBounds = true
            $0.backgroundColor = .clear
        }.make(container) {
            $0.leading.equalTo(searchIconView.snp.trailing).offset(8.rpx)
            $0.trailing.equalToSuperview().offset(-12.rpx)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20.rpx)
        }
    }

    /// 当前可见提示行。
    func lazyCurrentRow() -> VLHomeSearchHintRowView {
        VLHomeSearchHintRowView().make(hintClipView) {
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20.rpx)
        }
    }

    /// 自下方滚入的下一条提示行。
    func lazyNextRow() -> VLHomeSearchHintRowView {
        VLHomeSearchHintRowView().then {
            $0.alpha = 0
        }.make(hintClipView) {
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20.rpx)
        }
    }

    /// 展示指定下标提示。
    func applyHint(at index: Int, animated: Bool) {
        guard !hints.isEmpty else {
            let fallback = VLHomeSearchHintDisplay.make(from: nil)
            currentRow.configure(fallback)
            currentRow.transform = .identity
            currentRow.alpha = 1
            nextRow.alpha = 0
            return
        }
        let safeIndex = ((index % hints.count) + hints.count) % hints.count
        currentIndex = safeIndex
        let display = VLHomeSearchHintDisplay.make(from: hints[safeIndex])
        if animated {
            animateToNext(display)
        } else {
            currentRow.configure(display)
            currentRow.transform = .identity
            currentRow.alpha = 1
            nextRow.transform = .identity
            nextRow.alpha = 0
        }
    }

    /// 当前行上移淡出，下一行自底部滚入。
    func animateToNext(_ next: VLHomeSearchHintDisplay) {
        nextRow.configure(next)
        nextRow.alpha = 1
        nextRow.transform = CGAffineTransform(translationX: 0, y: 20.rpx)
        currentRow.transform = .identity

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) {
            self.currentRow.transform = CGAffineTransform(translationX: 0, y: -20.rpx)
            self.currentRow.alpha = 0
            self.nextRow.transform = .identity
        } completion: { finished in
            guard finished else { return }
            self.currentRow.configure(next)
            self.currentRow.transform = .identity
            self.currentRow.alpha = 1
            self.nextRow.alpha = 0
            self.nextRow.transform = CGAffineTransform(translationX: 0, y: 20.rpx)
        }
    }

    /// 多条提示时启动定时轮播。
    func startAutoScrollIfNeeded() {
        stopAutoScroll()
        guard hints.count > 1, window != nil else { return }
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + 2.5, repeating: 2.5)
        timer.setEventHandler { [weak self] in
            self?.advanceHint()
        }
        timer.resume()
        scrollTimer = timer
    }

    /// 前进到下一条提示（自下而上）。
    func advanceHint() {
        guard hints.count > 1 else { return }
        applyHint(at: currentIndex + 1, animated: true)
    }

    /// 取消轮播定时器。
    func stopAutoScroll() {
        scrollTimer?.cancel()
        scrollTimer = nil
    }

    /// 通过 VM 处理搜索栏点击。
    @objc func searchTapped() {
        weakView(fetch: VLHomeExchangeView.self)?.vm.onSearchTap()
    }
}
