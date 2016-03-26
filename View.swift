import UIKit

struct offSetScale {
    var offSet: CGPoint
    var scale: CGPoint
    
    func myPercent(percent:CGFloat) -> offSetScale {
        let os = CGPoint(x: offSet.x * percent , y: offSet.y * percent)
        let sc = percentMultipleCo(scale, percent: percent)
        return offSetScale(offSet: os, scale: sc)
    }
    
    
    private func percentMultipleCo(scale: CGPoint, percent:CGFloat) -> CGPoint {
        return CGPoint(x: 1 + (scale.x-1) * percent,y:1 + (scale.y-1) * percent)
    }
}

extension UIView {
    func cornerize(length: CGFloat?) {
        self.layer.masksToBounds = true
        if length != nil {
            self.layer.cornerRadius = length!
        } else {
            self.layer.cornerRadius = self.frame.width/2
        }
    }
    
    func addSubViews(sub:[UIView]) {
        for i in sub {
            self.addSubview(i)
        }
    }
    
    func fillInSuperView() {
        assert(self.superview != nil, "no super view")
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraintEqualToAnchor(self.superview?.topAnchor).active = true
        self.leftAnchor.constraintEqualToAnchor(self.superview?.leftAnchor).active = true
        self.heightAnchor.constraintEqualToAnchor(self.superview?.heightAnchor).active = true
        self.widthAnchor.constraintEqualToAnchor(self.superview?.widthAnchor).active = true
    }
    
    // 从本身view，return的是变化
    func calculateTransform(toView: UIView, toFrame: CGRect) -> offSetScale {
        
       // find toViewCenter point relative to self coordinate system
        let translate = centerDistance(toView, toFrame: toFrame)
    
  
        // transform scale
        let sx = toFrame.width / self.frame.width
        let sy = toFrame.height / self.frame.height
        let scaleTransform = CGPoint(x: sx, y: sy)

        return offSetScale(offSet: CGPoint(x: translate.x,y:translate.y), scale: scaleTransform)
    }
    
    // 把change center and scale，这个para是最终的位置
    
    // 是toview center - self center，理论上来说，得两个view有共同的reference，但实际上就算没有共同，也不会报错
    func centerDistance(toView:UIView, toFrame: CGRect) -> CGPoint {

        let toViewCenter = self.superview!.convertPoint(CGPoint(x: toFrame.origin.x + toFrame.width/2, y: toFrame.origin.y + toFrame.height/2), fromView: toView)
        
        return CGPoint(x: toViewCenter.x - self.center.x, y: toViewCenter.y - self.center.y)
    }
    
    // return 的是变化
    func transformForView2(view2:UIView, ofsc:offSetScale) -> offSetScale {
        let distance = centerDistance(view2, toFrame: view2.bounds)

        let x = distance.x * (ofsc.scale.x-1) + ofsc.offSet.x
        let y = distance.y * (ofsc.scale.y-1) + ofsc.offSet.y
  
        return offSetScale(offSet: CGPoint(x: x,y:y), scale: ofsc.scale)
    }

    
    func allAnimate(fromFrame:CGRect, count:Int, duration:NSTimeInterval) {
        let fromX = fromFrame.origin.x + fromFrame.width/2
        let fromY = fromFrame.origin.y + fromFrame.height/2
        
        let x = (self.center.x - fromX) / CGFloat((count*2))
        let y = (self.center.y - fromY) / CGFloat((count*2))
        
        self.center = CGPoint(x: fromX, y: fromY)
        let scaleX = fromFrame.width / self.frame.width
        let scaleY = fromFrame.height / self.frame.height
        
        self.transform = CGAffineTransformMakeScale(scaleX, scaleY)
        
        var time = 1
        let factor:CGFloat = 1/(CGFloat(count)*2)
        let sx = pow(1/scaleX, factor)
        let sy = pow(1/scaleY, factor)
        
        func animate() {
            UIView.animateWithDuration(duration/(Double(count)*2), delay: 0, options: .CurveLinear, animations: {
                self.transform = CGAffineTransformRotate(self.transform, CGFloat(M_PI))
                self.transform = CGAffineTransformScale(self.transform, sx, sy)
                self.center = CGPoint(x: self.center.x + x, y: self.center.y + y)
                }, completion: {
                    _ in
                    time += 1
                    if time < count*2 + 1 {
                        animate()
                    }
            })
        }
        animate()
    }
}

extension UICollectionViewFlowLayout {
    func lengthForSectionAtIndex(index:Int) -> CGFloat {
        
        let collectionView = self.collectionView
        let itemsNumber = collectionView!.numberOfItemsInSection(index)
        let interSpace = self.minimumLineSpacing * CGFloat((itemsNumber - 1))
        
        if self.scrollDirection == .Horizontal {
            
            let footerWidth = collectionView?.layoutAttributesForSupplementaryElementOfKind(UICollectionElementKindSectionFooter, atIndexPath: NSIndexPath(forItem: 0, inSection: index))?.size.width
            let headerWidth = collectionView?.layoutAttributesForSupplementaryElementOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: index))?.size.width
            var itemsWidth:CGFloat = 0
            for i in 0..<itemsNumber {
                let width = collectionView?.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: i, inSection: index))?.size.width
                itemsWidth += width!
            }
            
            return footerWidth! + headerWidth! + itemsWidth + interSpace
        } else {
            let footerHeight = collectionView?.layoutAttributesForSupplementaryElementOfKind(UICollectionElementKindSectionFooter, atIndexPath: NSIndexPath(forItem: 0, inSection: index))?.size.height
            let headerHeight = collectionView?.layoutAttributesForSupplementaryElementOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: index))?.size.height
            var itemsHeight:CGFloat = 0
            for i in 0..<itemsNumber {
                let height = collectionView?.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: i, inSection: index))?.size.height
                itemsHeight += height!
            }
            return footerHeight! + headerHeight! + itemsHeight + interSpace
            
        }
    }
}
