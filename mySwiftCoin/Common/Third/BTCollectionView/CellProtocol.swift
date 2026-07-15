
import UIKit

public enum CellSelectState<T> {
    case didSelect(T)
    case didDeselect(T)
}





//MARK:- Cell
public protocol CellProtocol where Self: UICollectionViewCell {
    func cell(model: ItemTypeProtocol)
    
    func cell(didSelect model: ItemTypeProtocol)
    func cell(didSelect indexPath: IndexPath, model: ItemTypeProtocol)
    
    func cell(didDeselect model: ItemTypeProtocol)
    func cell(didDeselect indexPath: IndexPath, model: ItemTypeProtocol)
}



open class BaseCVCell: UICollectionViewCell, CellProtocol {
    open func cell(model: ItemTypeProtocol) {
        
    }

    open func cell(didSelect model: ItemTypeProtocol) {
        
    }
    
    open func cell(didSelect indexPath: IndexPath, model: ItemTypeProtocol) {
        cell(didSelect: model)
    }
    
    open func cell(didDeselect model: ItemTypeProtocol) {
        
    }
    
    open func cell(didDeselect indexPath: IndexPath, model: ItemTypeProtocol) {
        cell(didDeselect: model)
    }
}






//MARK:- ReusableView
public protocol ReusableViewProtocol where Self: UICollectionReusableView {
    func reusable(model: HeadFootTypeProtocol)
}

open class BaseCRView: UICollectionReusableView, ReusableViewProtocol{
    open func reusable(model: HeadFootTypeProtocol) {
        
    }
}

