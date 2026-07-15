import UIKit
import SnapKit
import Then

/// 促销 Banner 轮播；多页时首尾衔接，末页可继续滑回首页。
final class VLHomeBannerCell: BaseCVCell {

    private var banners: [VLHomeBannerSlideModel] = []
    /// 逻辑页（0..<banners.count）。
    private var currentIndex = 0
    private var scrollTimer: DispatchSourceTimer?
    private var lastLayoutWidth: CGFloat = 0
    /// 是否启用假首尾页做无限循环。
    private var isLooping: Bool { banners.count > 1 }

    private lazy var scrollView = lazyScrollView()
    private lazy var pageControl = lazyPageControl()

    /// 配置 Banner 幻灯片并启动自动轮播。
    override func cell(model: ItemTypeProtocol) {
        guard let item = model as? ItemTypeModel<VLHomeBannerModel> else { return }
        banners = item.data.banners
        lastLayoutWidth = 0
        currentIndex = 0
        rebuildSlidesIfNeeded(force: true)
        pageControl.numberOfPages = banners.count
        pageControl.currentPage = 0
        startAutoScrollIfVisible()
    }

    /// 离开复用池时停止定时器。
    override func prepareForReuse() {
        super.prepareForReuse()
        stopAutoScroll()
    }

    /// 仅在宽度变化时重建幻灯片。
    override func layoutSubviews() {
        super.layoutSubviews()
        rebuildSlidesIfNeeded(force: false)
    }

    /// 移出窗口时暂停定时器；可见时恢复。
    override func didMoveToWindow() {
        super.didMoveToWindow()
        window == nil ? stopAutoScroll() : startAutoScrollIfVisible()
    }
}

fileprivate extension VLHomeBannerCell {

    /// 含假页时的总页数（首尾各多 1 页）。
    var pageCount: Int {
        isLooping ? banners.count + 2 : banners.count
    }

    /// 逻辑页对应的 scroll 偏移页（loop 时 +1）。
    func scrollPage(forLogical index: Int) -> Int {
        isLooping ? index + 1 : index
    }

    /// 水平分页滚动视图。
    func lazyScrollView() -> UIScrollView {
        UIScrollView().then {
            $0.isPagingEnabled = true
            $0.isDirectionalLockEnabled = true
            $0.showsHorizontalScrollIndicator = false
            $0.backgroundColor = .clear
            $0.delegate = self
            $0.bounces = true
            $0.alwaysBounceHorizontal = true
        }.make(contentView) {
            $0.leading.trailing.equalToSuperview().inset(VLHomeLayout.horizontalInset)
            $0.top.equalToSuperview().offset(4.rpx)
            $0.height.equalTo(88.rpx)
        }
    }

    /// Banner 下方页码圆点指示器（居中）。
    func lazyPageControl() -> UIPageControl {
        UIPageControl().then {
            $0.currentPageIndicatorTintColor = VLHomeAppearance.textPrimary
            $0.pageIndicatorTintColor = VLHomeAppearance.textTertiary
            $0.isUserInteractionEnabled = false
        }.make(contentView) {
            $0.top.equalTo(scrollView.snp.bottom).offset(4.rpx)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(16.rpx)
        }
    }

    /// 强制或 scroll 宽度变化时重建幻灯片（含循环假页）。
    func rebuildSlidesIfNeeded(force: Bool) {
        let width = scrollView.bounds.width > 0 ? scrollView.bounds.width : AppWidth - 32.rpx
        guard force || width != lastLayoutWidth else { return }
        lastLayoutWidth = width
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        guard !banners.isEmpty else {
            scrollView.contentSize = .zero
            return
        }
        let slides = loopingSlides()
        scrollView.contentSize = CGSize(width: width * CGFloat(slides.count), height: 88.rpx)
        slides.enumerated().forEach { index, banner in
            let slide = makeSlide(banner: banner)
            slide.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: 88.rpx)
            scrollView.addSubview(slide)
        }
        scrollView.setContentOffset(
            CGPoint(x: width * CGFloat(scrollPage(forLogical: currentIndex)), y: 0),
            animated: false
        )
    }

    /// 多页时返回 [末, …全部…, 首]，单页原样。
    func loopingSlides() -> [VLHomeBannerSlideModel] {
        guard isLooping, let first = banners.first, let last = banners.last else {
            return banners
        }
        return [last] + banners + [first]
    }

    /// 构建单张 Banner 幻灯片卡片。
    func makeSlide(banner: VLHomeBannerSlideModel) -> UIView {
        UIView().then { card in
            card.backgroundColor = VLHomeAppearance.surface
            card.layer.cornerRadius = 8.rpx
            card.isUserInteractionEnabled = true
            card.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(bannerTapped))
            )
            let icon = UIImageView(image: UIImage(systemName: banner.iconName)).then {
                $0.tintColor = VLHomeAppearance.textPrimary
                $0.contentMode = .scaleAspectFit
                $0.backgroundColor = VLHomeAppearance.elevated
                $0.layer.cornerRadius = 8.rpx
                $0.clipsToBounds = true
            }
            icon.make(card) {
                $0.leading.equalToSuperview().offset(12.rpx)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(48.rpx)
            }
            UILabel().then {
                $0.text = banner.title
                $0.font = .systemFont(ofSize: 13)
                $0.textColor = VLHomeAppearance.textTertiary
            }.make(card) {
                $0.leading.equalTo(icon.snp.trailing).offset(12.rpx)
                $0.trailing.equalToSuperview().offset(-12.rpx)
                $0.top.equalToSuperview().offset(20.rpx)
            }
            UILabel().then {
                $0.text = banner.subtitle
                $0.font = .systemFont(ofSize: 14, weight: .medium)
                $0.textColor = VLHomeAppearance.textPrimary
                $0.numberOfLines = 2
            }.make(card) {
                $0.leading.equalTo(icon.snp.trailing).offset(12.rpx)
                $0.trailing.equalToSuperview().offset(-12.rpx)
                $0.top.equalToSuperview().offset(40.rpx)
            }
        }
    }

    /// 仅在 cell 可见且有多张幻灯片时启动自动滚动。
    func startAutoScrollIfVisible() {
        stopAutoScroll()
        guard window != nil, isLooping else { return }
        let timer = DispatchSource.makeTimerSource(queue: Main)
        timer.schedule(deadline: .now() + 3.0, repeating: 3.0)
        timer.setEventHandler { [weak self] in
            self?.advanceToNextPage(animated: true)
        }
        timer.resume()
        scrollTimer = timer
    }

    /// 前进一页（自动轮播）；末页后无缝回到首页。
    func advanceToNextPage(animated: Bool) {
        guard isLooping else { return }
        let width = scrollView.bounds.width
        guard width > 0 else { return }
        let nextScrollPage = scrollPage(forLogical: currentIndex) + 1
        scrollView.setContentOffset(CGPoint(x: width * CGFloat(nextScrollPage), y: 0), animated: animated)
        if !animated {
            normalizeLoopOffsetIfNeeded()
        }
    }

    /// 滚动结束后把假页瞬移到真实页，并同步逻辑索引。
    func normalizeLoopOffsetIfNeeded() {
        guard isLooping else {
            let width = scrollView.bounds.width
            guard width > 0 else { return }
            currentIndex = Int(round(scrollView.contentOffset.x / width))
            pageControl.currentPage = currentIndex
            return
        }
        let width = scrollView.bounds.width
        guard width > 0 else { return }
        let page = Int(round(scrollView.contentOffset.x / width))
        if page == 0 {
            currentIndex = banners.count - 1
            scrollView.setContentOffset(
                CGPoint(x: width * CGFloat(banners.count), y: 0),
                animated: false
            )
        } else if page == banners.count + 1 {
            currentIndex = 0
            scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: false)
        } else {
            currentIndex = page - 1
        }
        pageControl.currentPage = currentIndex
    }

    /// 取消自动滚动定时器。
    func stopAutoScroll() {
        scrollTimer?.cancel()
        scrollTimer = nil
    }

    /// 通过 VM 处理 Banner 点击。
    @objc func bannerTapped() {
        weakView(fetch: VLHomeExchangeView.self)?.vm.onBannerTap(index: currentIndex)
    }
}

extension VLHomeBannerCell: UIScrollViewDelegate {

    /// 用户拖拽时暂停自动滚动。
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }

    /// 动画滚动结束后归一化假页并恢复自动轮播。
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        normalizeLoopOffsetIfNeeded()
        startAutoScrollIfVisible()
    }

    /// 用户滚动结束后同步页码并恢复自动滚动。
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        normalizeLoopOffsetIfNeeded()
        startAutoScrollIfVisible()
    }
}
