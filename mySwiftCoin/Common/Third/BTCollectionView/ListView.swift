

import UIKit
import MJRefresh
import SnapKit
import Then

public class _ListView<ViewProxy: ModelProxyProtocol>: UIView {
    public lazy var myFlowLayout = lazyMyFlowLayout()
    public lazy var collectionView = lazyCollectionView()
    
    public var flowLayout: UICollectionViewFlowLayout?
    public lazy var cells = [CellProtocol.Type]()
    public lazy var spacingConfig = (lineSpacing: 0.rpx, interitemSpacing: 0.rpx)
    public lazy var contentInset = UIEdgeInsets.zero
    public lazy var isHeaderRefresh = false
    public lazy var isReloadScrollToTop = false
    
    public weak var delegate: ScrollViewDelegate?
    
    public var isFooterHandle: (() -> Bool?)?
    public var headerHandle: (() -> Void)?
    public var footerHandle: (() -> Void)?
    
    public func config(collectionView: UICollectionView) {
        
    }
    
    public func footerEnd(collectionView: UICollectionView) {
        UIView.animate(withDuration: 0.25) {
            collectionView.refreshFooter?.isHidden = true
        }
    }
}

extension _ListView: CollectionViewProtocol {
    public typealias Proxy = ViewProxy
}

fileprivate extension _ListView {
    func reloadData(modelsCount: Int, _ closure: () -> Void) {
        closure()
        
        if isReloadScrollToTop && modelsCount > 0 {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        After(isMain: true, delay: 0.5, { self.isAddFooter(collectionView: self.collectionView) })
    }
    
    func isAddFooter(collectionView: UICollectionView) {
        guard let isFooterHandle = isFooterHandle else { return }
        guard let footerResult = isFooterHandle(), footerResult else {
            footerEnd(collectionView: collectionView)
            return
        }
        
        if let footer = collectionView.refreshFooter { footer.isHidden = false }
        guard collectionView.refreshFooter == nil else { return }
        collectionView.footerNormalRefreshWeak(weakHandle { $0?.footerHandle?() })
    }
}

//MARK: -getter
fileprivate extension _ListView {
    func lazyMyFlowLayout() -> UICollectionViewFlowLayout {
        return flowLayout ?? UICollectionViewFlowLayout().then {
            $0.minimumInteritemSpacing = spacingConfig.interitemSpacing
            $0.minimumLineSpacing = spacingConfig.lineSpacing
        }
    }
    
    func lazyCollectionView() -> UICollectionView {
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: myFlowLayout).then {
            $0.backgroundColor = .clear
            $0.contentInset = contentInset
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.register(cells: cells)
            $0.dataSource(delegate: collectionProxy)
            collectionProxy?.delegate = delegate
            if isHeaderRefresh { $0.headerNormalRefreshWeak(weakHandle { $0?.headerHandle?() }) }
            
            config(collectionView: $0)
        }.make(self) {
            $0.edges.equalTo(self)
        }
    }
}









final public class ItemListView<ViewProxy: ItemProxy>: _ListView<ViewProxy> {
    
}

extension ItemListView {
    public var itemListModels: [ItemTypeProtocol] {
         proxyModels
    }
}

extension ItemListView {
    public func reload(models: [ItemTypeProtocol]) {
        reloadData(modelsCount: models.count) { proxyItemsReload(models: models) }
    }
}








final public class SectionListView<ViewProxy: SectionProxy>: _ListView<ViewProxy> {
    public lazy var headers = [UICRViewType]()
    public lazy var footers = [UICRViewType]()
    
    public override func config(collectionView: UICollectionView) {
        if !headers.isEmpty { collectionView.register(headers: headers) }
        if !footers.isEmpty { collectionView.register(footers: footers) }
    }
}

extension SectionListView {
    public var sectionListModels: [SectionTypeProtocol] {
        proxyModels
    }
}

extension SectionListView {
    public func reload(models: [SectionTypeProtocol]) {
        reloadData(modelsCount: models.count) { proxySectionReload(models: models) }
    }
}


