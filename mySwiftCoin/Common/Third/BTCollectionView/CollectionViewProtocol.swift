
import UIKit


//fileprivate var _COLLECTIONVIEW_PROXY_KEY = "CollectionViewProtocol._COLLECTIONVIEW_PROXY_KEY"
fileprivate var _COLLECTIONVIEW_PROXY_KEY: Void?

public protocol CollectionViewProtocol: AnyObject, AssociatedStrongProtocol  {
    associatedtype Proxy: ModelProxyProtocol
    var collectionView: UICollectionView { set get }
}



public extension CollectionViewProtocol {
    @inline(__always)
    var collectionProxy: CollectionProxy<Proxy>? {
        associatedObject(forKey: &_COLLECTIONVIEW_PROXY_KEY, default: CollectionProxy(sectionProxy: Proxy.new()))
    }
}



public extension CollectionViewProtocol where Proxy: ItemProxy {
    var proxyModels: [ItemTypeProtocol] {
        collectionProxy?.modelProxy.models ?? []
    }
    
    func proxyItemsReload(models: [ItemTypeProtocol]) {
        collectionProxy?.reload(models, completed: collectionView.reloadData())
    }
    
    func proxyInsertReload(indexPath: [IndexPath], models: [ItemTypeProtocol]) {
        collectionProxy?.reload(models, completed: collectionView.insertItems(at: indexPath))
    }
    
    func proxyDeleteReload(indexPath: [IndexPath], models: [ItemTypeProtocol]) {
        let count = proxyModels.count
        for index in indexPath {
            guard index.row < count && index.item < count else { return }
        }
        collectionProxy?.reload(models, completed: collectionView.deleteItems(at: indexPath))
    }
}




public extension CollectionViewProtocol where Proxy: SectionProxy {
    var proxyModels: [SectionTypeProtocol] {
        collectionProxy?.modelProxy.models ?? []
    }
    
    func proxySectionReload(models: [SectionTypeProtocol]) {
        collectionProxy?.reload(models, completed: collectionView.reloadData())
    }
    
    func proxyInsertReload(indexPath: [IndexPath], models: [SectionTypeProtocol]) {
        collectionProxy?.reload(models, completed: collectionView.insertItems(at: indexPath))
    }
    
    func proxyDeleteReload(indexPath: [IndexPath], models: [SectionTypeProtocol]) {
        collectionProxy?.reload(models, completed: collectionView.deleteItems(at: indexPath))
    }
    
    func proxySectionReloadSections(indexSet: IndexSet , models: [SectionTypeProtocol]) {
        collectionProxy?.reload(models, completed: collectionView.reloadSections(indexSet))
    }
    
    func proxySectionDeleteSections(indexSet: IndexSet , models: [SectionTypeProtocol]) {
        guard !models.isEmpty else { return }
        collectionProxy?.reload(models, completed: collectionView.deleteSections(indexSet))
    }
    
    func proxySectionInsertSections(indexSet: IndexSet , models: [SectionTypeProtocol]) {
        collectionProxy?.reload(models, completed: collectionView.insertSections(indexSet))
    }
}








