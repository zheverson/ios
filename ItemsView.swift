
import UIKit

class ItemsDisplayView: UIScrollView {
    let itemsImageHeight: CGFloat = 80
    let itemsInterSpace: CGFloat = 40
    let sameTimeItemSpace: CGFloat = 10
    
    var itemsID:[[[Double]]]
    var itemsImageView = [[UIImageView]]()
    
    init(frame: CGRect, itemsID:[[[Double]]]) {
        self.itemsID = itemsID
        super.init(frame: frame)
        var xAxis:CGFloat = frame.width
        
        for (itemindex, items) in itemsID.enumerate() {
            for (index, item) in items.enumerate() {
                
                let itemWidth = itemsImageHeight * CGFloat(item[1])
                let nsurl = NSURL(string: "http://54.223.65.44:8100/static/image/item_thumbnail/" + String(Int(item[0])))
                
                let view = UIImageView()
                if index == 0 {
                    itemsImageView.append([view])
                } else {
                    xAxis = xAxis - (itemsInterSpace - sameTimeItemSpace)
                    itemsImageView[itemindex].append(view)
                }
                
                view.frame = CGRect(x: xAxis, y: 10, width:itemWidth , height: itemsImageHeight)
                view.startDownload(nsurl!)
                xAxis += (itemsInterSpace + itemWidth)
                self.addSubview(view)
            }
        }
        contentSize = CGSize(width: xAxis, height: self.frame.height)
    }
    
    func itemViewOffset(second:CGFloat, timeline:[CGFloat]) -> CGFloat {
        let item1Width = itemsImageHeight * CGFloat(self.itemsID[0][0][1])
        var itemOffset = item1Width + itemsInterSpace/2 + self.frame.width/2
        if second < timeline[2] {
            return itemOffset * second/(timeline[2])
            
        } else if second > timeline[timeline.count - 1] {
            return 1.5
            
        } else {
            for index in 2.stride(through: timeline.count-2, by: 2) {
                if second >= timeline[index] && second < timeline[index+2] {
                    
                    let itemWidth = itemGroupWidth(index/2)
                    
                    for i in 4.stride(through: index, by: 2) {
                        itemOffset = itemOffset + itemGroupWidth((i-2)/2) + itemsInterSpace
                    }
                    let secondPercent = (second-timeline[index])/(timeline[index+2]-timeline[index])
                    
                    return itemOffset + (itemWidth + itemsInterSpace) * secondPercent
                }
            }
        }
        print("not possible")
        return 1
    }
    
    func itemGroupWidth(index: Int) -> CGFloat {
        var width:CGFloat = 0
        for item in self.itemsID[index]{
            width += itemsImageHeight * CGFloat(item[1])
        }
        width += sameTimeItemSpace * CGFloat((self.itemsID[index].count - 1))
        return width
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ItemsInfoView: UIView {
    
    var price:UILabel?
    var name:UILabel?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        name = UILabel(frame: CGRect(x: 10, y: 10, width: 50, height: 20))
        name?.textColor = UIColor.blackColor()
        price = UILabel(frame: CGRect(x: 10, y: 40, width: 30, height: 20))
        price?.textColor = UIColor.blackColor()
        price?.sizeToFit()
        let like = UIButton(frame: CGRect(x: 300, y: 20, width: 35, height: 35))
        like.setImage(UIImage(data: NSData(contentsOfURL: NSURL(string: host + "static/image/util/like")!)!), forState: .Normal)
        
        let cart = UIButton(frame: CGRect(x: 300, y: 100, width: 35, height: 35))
        cart.setImage(UIImage(data: NSData(contentsOfURL: NSURL(string: host + "static/image/util/cart")!)!), forState: .Normal)
        self.addSubViews([name!,price!,like,cart])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}