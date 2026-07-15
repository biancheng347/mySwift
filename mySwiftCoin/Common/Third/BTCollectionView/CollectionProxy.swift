
import UIKit
import Then



public class CollectionProxy<T: ModelProxyProtocol>: ScrollViewProxy,
                                                      UICollectionViewDataSource,
                                                      UICollectionViewDelegate,
                                                      UICollectionViewDelegateFlowLayout {
    public private(set) var modelProxy: T
    init(sectionProxy: T) {
        self.modelProxy = sectionProxy
    }
    
    //UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int  {
        return modelProxy.modelProxyOfSections()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelProxy.modelProxy(numberOfItemsInSection: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = modelProxy.modelProxy(cellForItemAt: indexPath)
        return collectionView.cell(index: indexPath, item: item)
    }
    
    //UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout, flowLayout.minimumLineSpacing > 0 {
            return flowLayout.minimumLineSpacing
        }
        return modelProxy.modelProxy(minimumLineSpacingForSectionAt: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout, flowLayout.minimumInteritemSpacing > 0 {
            return flowLayout.minimumInteritemSpacing
        }
        return modelProxy.modelProxy(minimumInteritemSpacingForSectionAt: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return modelProxy.modelProxy(sizeForItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return modelProxy.modelProxy(referenceSizeForHeaderInSection: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return modelProxy.modelProxy(referenceSizeForFooterInSection: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return modelProxy.modelProxy(insetForSectionAt: section)
    }
    
    //UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return reuableView(collecionView: collectionView, kind: kind, indexPath: indexPath) { view, index, item in
            view.reusable(model: item)
        } ?? UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CellProtocol else { return }
        
        let item = modelProxy.modelProxy(didSelectItemAt: indexPath)
        
        collectionView.didSelect(cell: cell, collectionView: collectionView, indexPath: indexPath, model: item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CellProtocol else { return }
        
        let item = modelProxy.modelProxy(didSelectItemAt: indexPath)
        collectionView.didDeselect(cell: cell, collectionView: collectionView, indexPath: indexPath, model: item)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return modelProxy.modelProxy(canMoveItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        modelProxy.modelProxy(moveItemAt: sourceIndexPath, to: destinationIndexPath)
    }
}


extension CollectionProxy where T: ModelProxyProtocol{
    func reload(_ models: [ItemTypeProtocol], config: @escaping (T) -> Void, completed: @autoclosure () -> Void) {
        config(modelProxy)
        completed()
    }
}


extension CollectionProxy where T: ItemProxy {
    func reload(_ models: [ItemTypeProtocol], completed: @autoclosure () -> Void) {
        modelProxy.update(models: models)
        completed()
    }
}


extension CollectionProxy where T: SectionProxy {
    func reload(_ models: [SectionTypeProtocol], completed: @autoclosure () -> Void) {
        modelProxy.update(models: models)
        completed()
    }
}


//MARK:- cell
extension UICollectionView {
    func cell(index: IndexPath, item: ItemTypeProtocol) -> UICollectionViewCell {
        return dequeueReusableCell(withReuseIdentifier: item.cellTypeStr, for: index).then {
            ($0 as? CellProtocol)?.cell(model: item)
        }
    }
}


//MARK:- didSelect
extension UICollectionView {
    func didSelect(cell:CellProtocol, collectionView: UICollectionView, indexPath: IndexPath, model: ItemTypeProtocol) {
        cell.cell(didSelect: indexPath, model: model)
    }
    
    func didDeselect(cell:CellProtocol, collectionView: UICollectionView, indexPath: IndexPath, model: ItemTypeProtocol) {
        cell.cell(didDeselect: indexPath, model: model)
    }
}


//MARK: - kind view
extension CollectionProxy {
    @discardableResult
    func reuableView(collecionView: UICollectionView,
                     kind: String,
                     indexPath: IndexPath,
                     _ closure: @escaping (BaseCRView, IndexPath, HeadFootTypeProtocol) -> Void) -> UICollectionReusableView? {
        let headerFooter = modelProxy.modelProxy(viewForSupplementaryElement: indexPath)
        
        guard let hfItem = kind == UICollectionView.elementKindSectionHeader ? headerFooter.header : headerFooter.footer else { return nil }
        return collecionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: hfItem.reusableTypeStr, for: indexPath).then {
            ($0 as? BaseCRView).map { closure($0, indexPath, hfItem) }
        }
    }
}

