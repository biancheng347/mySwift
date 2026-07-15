
import UIKit

public typealias UICView = UICollectionView
public typealias UICVCell = UICollectionViewCell
public typealias UICVCellType = UICollectionViewCell.Type

public typealias UICRView = UICollectionReusableView
public typealias UICRViewType = UICollectionReusableView.Type


fileprivate let HeaderKind = UICollectionView.elementKindSectionHeader
fileprivate let FooterKind = UICollectionView.elementKindSectionFooter

//MARK:- register
public extension UICollectionView {
    @discardableResult
    func register(cells: UICVCellType ...) -> Self {
        return register(cells: cells)
    }
    
    @discardableResult
    func register(cells: [UICVCellType]) -> Self {
        cells.forEach { self.register($0, forCellWithReuseIdentifier: $0.str) }
        return self
    }
    
    @discardableResult
    func register(headers: UICRViewType ...) -> Self{
        return register(headers: headers)
    }
    
    @discardableResult
    func register(headers: [UICRViewType]) -> Self{
        headers.forEach { self.register($0, forSupplementaryViewOfKind: HeaderKind, withReuseIdentifier: $0.str) }
        return self
    }
    
    @discardableResult
    func register(footers: UICRViewType ...) -> Self{
        return register(footers: footers)
    }
    
    @discardableResult
    func register(footers: [UICRViewType]) -> Self{
        footers.forEach { self.register($0, forSupplementaryViewOfKind: FooterKind, withReuseIdentifier: $0.str) }
        return self
    }
}

public extension UICollectionView {
    func dataSource<T: UICollectionViewDelegate & UICollectionViewDataSource>(delegate: T?)  {
        self.delegate = delegate
        self.dataSource = delegate
    }
}

