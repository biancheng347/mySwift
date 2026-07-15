//
//  CollectionView+refresh.swift
//  vanlink
//
//  Created by jackwang on 2025/8/8.
//

import UIKit
import MJRefresh
import RxCocoa
import RxSwift
import Then

//https://www.cnblogs.com/xujiahui/p/6808018.html
public enum RefreshAction {
    case header
    case footer
}

public enum RefreshStatus {
    case none
    case beginHeaderRefresh
    case endHeaderRefresh
    case beginFooterRefresh
    case endFooterRefresh
    case noMoreData
}


public extension UICollectionView {
    @discardableResult
    func headerNormalRefreshWeak(_ closure: @escaping () -> Void) -> Self {
        self.mj_header = VLHeaderRefresh(refreshingBlock: closure)
        return self
    }
    
    @discardableResult
    func footerNormalRefreshWeak(_ closure: @escaping () -> Void) -> Self {
        self.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: closure)
        return self
    }
}


public extension UICollectionView {
    @discardableResult
    func headerOldNormalRefreshWeak(_ closure: @escaping () -> Void) -> Self {
        self.mj_header = MJRefreshNormalHeader(refreshingBlock: closure)
        return self
    }
}


public extension UICollectionView {
    var refreshHeader: MJRefreshHeader? {
        return self.mj_header
    }
    
    var refreshFooter: MJRefreshFooter? {
        return self.mj_footer
    }
}



public extension UICollectionView {
    func refresh(state: RefreshStatus) {
        switch state {
        case .beginHeaderRefresh:
            header { $0.beginRefreshing() }
        case .endHeaderRefresh:
            header { $0.endRefreshing() }
        case .beginFooterRefresh:
            footer { $0.beginRefreshing() }
        case .endFooterRefresh:
            footer { $0.endRefreshing() }
        case .noMoreData:
            footer { $0.endRefreshingWithNoMoreData() }
        default: break
        }
    }
    
    func refresh(states: [RefreshStatus]) {
        states.forEach(refresh(state:))
    }
}



extension Reactive where Base: UICollectionView {
    public var refreshStatus: Binder<RefreshStatus> {
        return Binder(self.base) { v, status in
            v.refresh(state: status)
        }
    }
}


fileprivate extension UICollectionView {
    func header(_ closure: (MJRefreshHeader) -> Void) {
        if let head = mj_header {
            closure(head)
        }
    }
    
    func footer(_ closure: (MJRefreshFooter) -> Void) {
        if let footer = mj_footer {
            closure(footer)
        }
    }
}



class VLHeaderRefresh: MJRefreshNormalHeader {
    override func placeSubviews() {
        super.placeSubviews()
        
        if let lastUpdatedTimeLabel = lastUpdatedTimeLabel {
            lastUpdatedTimeLabel.isHidden = true
        }
        stateLabel?.isHidden = true
        arrowView?.isHidden = true
        loadingView?.isHidden = false
        loadingView?.do {
            $0.style = .medium
            $0.color = .label
            $0.startAnimating()
        }
    }
}
