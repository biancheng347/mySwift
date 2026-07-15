
import Foundation
import Then

public enum ReloadState<T> {
    case none
    case insert(T)
    case delete(T)
    case section(IndexSet)
    case insertSection(IndexSet)
    case deleteSection(IndexSet)
}



public class DataAndState<T, U> {
    public var models: T
    public var operation: ReloadState<U>
    
    public init(models: T, operation: ReloadState<U> = .none) {
        self.models = models
        self.operation = operation
    }
}







public class ItemTypeModel<T>: ItemTypeProtocol, Then {
    public var data: T
    public init(data: T) {
        self.data = data
    }
    
    public var cellTypeStr: String = ""
    public var cellSizeWidth: Double = 0
    public var cellSizeHeight: Double = 0
}






public class HeadFootTypeModel<T>: HeadFootTypeProtocol, Then {
    public var data: T
    public init(data: T) {
        self.data = data
    }
    
    public var reusableTypeStr: String = ""
    public var reusableSizeWidth: Double = 0
    public var reusableSizeHeight: Double = 0
}







public class SectionTypeModel: SectionTypeProtocol, Then {
    public var header: HeadFootTypeProtocol?
    public var items = [ItemTypeProtocol]()
    public var footer: HeadFootTypeProtocol?
    
    public init(header: HeadFootTypeProtocol? = nil,
                items: [ItemTypeProtocol],
                footer: HeadFootTypeProtocol? = nil) {
        self.header = header
        self.items = items
        self.footer = footer
    }
}






public protocol ItemTypeConfigProtocol {
    var conf: (type: String, width: Double, height: Double) { get }
}

public extension ItemTypeModel {
    func confItem(type: ItemTypeConfigProtocol) -> Self {
        let conf = type.conf
        return confItem(type: conf.type, width: conf.width, height: conf.height)
    }
    
    func confItem(type: String, width: Double, height: Double) -> Self {
        cellTypeStr = type
        cellSizeWidth = width
        cellSizeHeight = height
        return self
    }
}







public protocol HeadFootTypeConfigProtocol {
    var conf: (type: String, width: Double, height: Double) { get }
}

public extension HeadFootTypeModel {
    func confHeadFoot(type: HeadFootTypeConfigProtocol) -> Self {
        let conf = type.conf
        return confHeadFoot(type: conf.type, width: conf.width, height: conf.height)
    }
    
    func confHeadFoot(type: String, width: Double, height: Double) -> Self {
        reusableTypeStr = type
        reusableSizeWidth = width
        reusableSizeHeight = height
        return self
    }
}
