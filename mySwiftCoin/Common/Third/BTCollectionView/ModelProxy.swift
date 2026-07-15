
import UIKit


//MARK:- model for ucollection data
public protocol ModelProxyProtocol {
    static func new() -> Self
    
    func modelProxyOfSections() -> Int
    func modelProxy(numberOfItemsInSection section: Int) -> Int
    func modelProxy(cellForItemAt indexPath: IndexPath) -> ItemTypeProtocol //require
    
    func modelProxy(referenceSizeForHeaderInSection section: Int) -> CGSize
    func modelProxy(referenceSizeForFooterInSection section: Int) -> CGSize
    
    func modelProxy(minimumLineSpacingForSectionAt section: Int) -> CGFloat
    func modelProxy(minimumInteritemSpacingForSectionAt section: Int) -> CGFloat

    func modelProxy(insetForSectionAt section: Int) -> UIEdgeInsets
    
    func modelProxy(viewForSupplementaryElement indexPath: IndexPath) -> (header: HeadFootTypeProtocol?, footer: HeadFootTypeProtocol?)
    
    func modelProxy(canMoveItemAt indexPath: IndexPath) -> Bool
    func modelProxy(moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    
    func modelProxy(indexPath: IndexPath, model: ItemTypeProtocol)
}







public extension ModelProxyProtocol {
    func modelProxyOfSections() -> Int {
        return 1
    }
    
    func modelProxy(numberOfItemsInSection section: Int) -> Int {
        return 0;
    }
    
    func modelProxy(sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = modelProxy(cellForItemAt: indexPath)
        if item.cellSizeWidth < 0 || item.cellSizeHeight < 0 { return CGSize.zero }
        return CGSize(width: item.cellSizeWidth, height: item.cellSizeHeight)
    }
    
    func modelProxy(referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func modelProxy(referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func modelProxy(minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func modelProxy(minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func modelProxy(insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func modelProxy(viewForSupplementaryElement indexPath: IndexPath) -> (header:HeadFootTypeProtocol?, footer:HeadFootTypeProtocol?) {
        return (nil, nil)
    }
    
    func modelProxy(didSelectItemAt indexPath: IndexPath) -> ItemTypeProtocol {
        return modelProxy(cellForItemAt: indexPath)
    }
    
    func modelProxy(canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func modelProxy(moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    func modelProxy(indexPath: IndexPath, model: ItemTypeProtocol) {
        
    }
}






open class SectionProxy: ModelProxyProtocol {
    public class func new() -> Self {
        return self.init(models: [])
    }
    
    open private(set) var models: [SectionTypeProtocol]
    
    required public init(models: [SectionTypeProtocol]) {
        self.models = models
    }
    
    open func update(models: [SectionTypeProtocol]) {
        self.models = models
    }

    open func modelProxyOfSections() -> Int {
        return models.count
    }
    
    open func modelProxy(numberOfItemsInSection section: Int) -> Int {
        let model = models[section]
        return model.items.count
    }
    
    open func modelProxy(cellForItemAt indexPath: IndexPath) -> ItemTypeProtocol {
        let model = models[indexPath.section]
        let item = model.items[indexPath.row]
        return item
    }
    
    open func modelProxy(minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func modelProxy(minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func modelProxy(sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = modelProxy(cellForItemAt: indexPath)
        if item.cellSizeWidth < 0 || item.cellSizeHeight < 0 { return CGSize.zero }
        return CGSize(width: item.cellSizeWidth, height: item.cellSizeHeight)
    }
    
    open func modelProxy(referenceSizeForHeaderInSection section: Int) -> CGSize {
        let model = models[section]
        if let header = model.header, header.reusableSizeWidth >= 0 && header.reusableSizeHeight >= 0 {
            return CGSize(width: header.reusableSizeWidth, height: header.reusableSizeHeight)
        }
        return CGSize.zero
    }
    
    open func modelProxy(referenceSizeForFooterInSection section: Int) -> CGSize {
        let model = models[section]
        if let footer = model.footer, footer.reusableSizeWidth >= 0 && footer.reusableSizeHeight >= 0 {
            return CGSize(width: footer.reusableSizeWidth, height: footer.reusableSizeHeight)
        }
        return CGSize.zero
    }
    
    open func modelProxy(viewForSupplementaryElement indexPath: IndexPath) -> (header: HeadFootTypeProtocol?, footer: HeadFootTypeProtocol?) {
        let model = models[indexPath.section]
        return (header: model.header, footer: model.footer)
    }
    
    open func modelProxy(insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    open func modelProxy(indexPath: IndexPath, model: ItemTypeProtocol) {
        
    }
}








open class ItemProxy: ModelProxyProtocol {
    public class func new() -> Self {
        return self.init(models: [])
    }
    
    open private(set) var models: [ItemTypeProtocol]
    
    required public init(models: [ItemTypeProtocol]) {
        self.models = models
    }
    
    open func update(models: [ItemTypeProtocol]) {
        self.models = models
    }

    open func modelProxyOfSections() -> Int {
        return 1
    }
    
    open func modelProxy(numberOfItemsInSection section: Int) -> Int {
      return models.count
    }
    
    open func modelProxy(cellForItemAt indexPath: IndexPath) -> ItemTypeProtocol {
        let item = models[indexPath.row]
        return item
    }
    
    open func modelProxy(minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func modelProxy(minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func modelProxy(sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = modelProxy(cellForItemAt: indexPath)
        if item.cellSizeWidth < 0 || item.cellSizeHeight < 0 { return CGSize.zero }
        return CGSize(width: item.cellSizeWidth, height: item.cellSizeHeight)
    }
    
    open func modelProxy(referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    open func modelProxy(referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    open func modelProxy(insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    open func modelProxy(viewForSupplementaryElement indexPath: IndexPath) -> (header:HeadFootTypeProtocol?, footer:HeadFootTypeProtocol?) {
        return (nil, nil)
    }
    
    open func modelProxy(didSelectItemAt indexPath: IndexPath) -> ItemTypeProtocol {
        return modelProxy(cellForItemAt: indexPath)
    }
    
    open func modelProxy(canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func modelProxy(moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    open func modelProxy(indexPath: IndexPath, model: ItemTypeProtocol) {
        
    }
}


