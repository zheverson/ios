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
    let y:CGFloat = 30
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func updateItems(items:[itemsInfo]) {
        
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
            print(self.frame)
            print(cell.frame)
            let frame = self.convertRect(item.frame, fromView: nil)
            cell.allAnimate(frame, count: 2, duration: 3)
        }
    }

}

class itemCell:UIView {
    
    var fromFrame:CGRect?
    
    init(frame: CGRect, info:itemsInfo) {
        super.init(frame: frame)
        //self.backgroundColor = UIColor.greenColor()
        let name = UILabel(frame: CGRect(x: 20, y: 20, width: self.frame.width-30, height: 20))
        let price = UILabel(frame: CGRect(x: 20, y: 60, width: self.frame.width-30, height: 20))
        
        name.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        price.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.addSubview(name)
        self.addSubview(price)
        
        name.font = font1
        price.font = font1
        name.text = info.name
        price.text = String(info.price)
        name.sizeToFit()
        price.sizeToFit()
        
        self.fromFrame = info.frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct itemsInfo {
    var name:String
    var price:Double
    var frame:CGRect
    
    init(name:String, price:Double, frame:CGRect){
        self.name = name
        self.price = price
        self.frame = frame
    }
}