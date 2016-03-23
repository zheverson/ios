//
//  itemsInfoView.swift
//  ibuydeal
//
//  Created by jiangjiang on 3/17/16.
//  Copyright © 2016 jiangjiang. All rights reserved.
//

import UIKit

class itemsInfoView: UIView {
    
    let horizontalSpace = 20
    let y:CGFloat = 10
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func updateItems(items:[Item], fromFrame:[CGRect]) {
        
        if self.subviews.count != 0 {
            for v in self.subviews {
                v.removeFromSuperview()
            }
        }
        let number = items.count
        
        for (index,item) in items.enumerate() {
            let x = self.frame.width * CGFloat(index/number)
            let cell = itemCell(frame: CGRect(x: x, y: y, width: self.frame.width/CGFloat(number), height: self.frame.height - y*2), info: item)
            self.addSubview(cell)
            let frame = self.convertRect(fromFrame[index], fromView: nil)
            cell.allAnimate(frame, count: 2, duration: 1.5)
        }
    }

}

class itemCell:UIView {
    
    init(frame: CGRect, info:Item) {
        super.init(frame: frame)
        //self.backgroundColor = UIColor.greenColor()
        let name = UILabel(frame: CGRect(x: 10, y: 50, width: self.frame.width-30, height: 20))
        let price = UILabel(frame: CGRect(x: 10, y: 80, width: self.frame.width-30, height: 20))
        let brand = UILabel(frame: CGRect(x: 10, y: 20, width: self.frame.width-30, height: 20))
        
        name.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        price.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        brand.autoresizingMask = name.autoresizingMask
        
        self.addSubViews([brand,name,price])
        
        name.font = font1
        price.font = font1
        brand.font = font1
        brand.text = info.brand!
        name.text = info.name!
        price.text = "￥\(info.price!)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
