
import UIKit


//MARK:- item type
public protocol ItemTypeProtocol {
    var cellTypeStr: String { set get }
    var cellSizeWidth: Double { set get }
    var cellSizeHeight: Double { set get }
}

public protocol ItemTypeOtherProtocol: ItemTypeProtocol {
    var cellOther: String { set get }
}







//MARK:- HeaderFooter
public protocol HeadFootTypeProtocol  {
    var reusableTypeStr: String { set get }
    var reusableSizeWidth: Double { set get }
    var reusableSizeHeight: Double { set get }
}

public protocol HeadFootTypeOtherProtocol: HeadFootTypeProtocol {
    var reusableOther: String { set get }
}






public typealias SectionTypeProtocol = HeaderProtocol & ItemsProtocol & FooterProtocol
public protocol HeaderProtocol {
    var header: HeadFootTypeProtocol? { set get }
}

public protocol FooterProtocol {
    var footer: HeadFootTypeProtocol? { set get }
}

public protocol ItemsProtocol {
    var items: [ItemTypeProtocol] { set get }
}






