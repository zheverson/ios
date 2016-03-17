//
//  shadowArrowView.swift
//  item
//
//  Created by jiangjiang on 3/8/16.
//  Copyright © 2016 jiangjiang. All rights reserved.
//

import UIKit

class shadowArrowView: UIView {
    
    let arrowHeight:CGFloat = 10
    let arrowWidth:CGFloat = 20
    
    
    override func drawRect(rect: CGRect) {
        let con = UIGraphicsGetCurrentContext()!

        let w = rect.width
        let h = rect.height-10
        
        CGContextSetShadow(con, CGSize(width: 0, height: 1), 4)
        CGContextSetFillColorWithColor(con, UIColor.whiteColor().CGColor)
        CGContextMoveToPoint(con, 0, 0)
        CGContextAddLineToPoint(con, 0, h - arrowHeight)
        CGContextAddLineToPoint(con, (w - arrowWidth)/2, h - arrowHeight)
        CGContextAddLineToPoint(con, w/2, h)
        CGContextAddLineToPoint(con, (w + arrowWidth)/2, h - arrowHeight)
        CGContextAddLineToPoint(con, w, h - arrowHeight)
        CGContextAddLineToPoint(con, w, 0)
        CGContextClosePath(con)
        CGContextFillPath(con)
    }
}


