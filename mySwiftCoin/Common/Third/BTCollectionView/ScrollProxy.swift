

import UIKit


//MARK:- ScrollDelegateProtocol
public protocol ScrollViewDelegate: AnyObject  {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    
    func scrollViewDidZoom(_ scrollView: UIScrollView)
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?)
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat)
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView)
    
    @available(iOS 11.0, *)
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView)
}


public extension ScrollViewDelegate {
    //scrollView滚动时，就调用该方法。任何offset值改变都调用该方法。即滚动过程中，调用多次
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // 当scrollView缩放时，调用该方法。在缩放过程中，回多次调用
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
    
    // 当开始滚动视图时，执行该方法。一次有效滑动（开始滑动，滑动一小段距离，只要手指不松开，只算一次滑动），只执行一次。
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    // 滑动scrollView，并且手指离开时执行。一次有效滑动，只执行一次。
    // 当pagingEnabled属性为YES时，不调用，该方法
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    
    // 滑动视图，当手指离开屏幕那一霎那，调用该方法。一次有效滑动，只执行一次。
    // decelerate,指代，当我们手指离开那一瞬后，视图是否还将继续向前滚动（一段距离），经过测试，decelerate=YES
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    // 滑动减速时调用该方法。
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    // 滚动视图减速完成，滚动将停止时，调用该方法。一次有效滑动，只执行一次。
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    // 当滚动视图动画完成后，调用该方法，如果没有动画，那么该方法将不被调用
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
    
    // 返回将要缩放的UIView对象。要执行多次
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    // 当将要开始缩放时，执行该方法。一次有效缩放，就只执行一次。
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    
    // 当缩放结束后，并且缩放大小回到minimumZoomScale与maximumZoomScale之间后（我们也许会超出缩放范围），调用该方法。
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
    }
    
    // 指示当用户点击状态栏后，滚动视图是否能够滚动到顶部。需要设置滚动视图的属性：_scrollView.scrollsToTop=YES;
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    // 当滚动视图滚动到最顶端后，执行该方法
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
    }
    
    @available(iOS 11.0, *)
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        
    }
}







public class ScrollViewProxy: NSObject {
    public weak var delegate: ScrollViewDelegate?
}

extension ScrollViewProxy: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidZoom(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDecelerating(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndDecelerating(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return delegate?.viewForZooming(in: scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.scrollViewWillBeginZooming(scrollView, with: view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        delegate?.scrollViewDidEndZooming(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        guard let _delegate = delegate else { return true }
        return _delegate.scrollViewShouldScrollToTop(scrollView)
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScrollToTop(scrollView)
    }
    
    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidChangeAdjustedContentInset(scrollView)
    }
}
