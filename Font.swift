
import UIKit

public let font1 = "IowanOldStyle-Roman"
public let nameSize:CGFloat = 13

public let contentTitleFont = UIFont(name: font1, size: 13)

extension String {
    func heightForText(width:CGFloat, font:UIFont) -> CGFloat {
        return (self as NSString).boundingRectWithSize(CGSize(width: width,height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size.height
    }
}