import UIKit

extension UIView {
    func cornerize(ratio: CGFloat?) {
        self.layer.masksToBounds = true
        if ratio != nil {
            self.layer.cornerRadius = ratio!
        } else {
            self.layer.cornerRadius = self.frame.width/2
        }
    }
    
    func nextViewOrigin() -> CGPoint {
        let x = self.frame.origin.x + self.frame.width
        let y = self.frame.origin.y + self.frame.height
        return CGPoint(x: x, y: y)
    }
    
    func addSubViews(sub:[UIView]) {
        for i in sub {
            self.addSubview(i)
        }
    }
    
    func fillInSuperView() {
        guard self.superview != nil else {
            print("no super view")
            return
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraintEqualToAnchor(self.superview?.topAnchor).active = true
        self.leftAnchor.constraintEqualToAnchor(self.superview?.leftAnchor).active = true
        self.heightAnchor.constraintEqualToAnchor(self.superview?.heightAnchor).active = true
        self.widthAnchor.constraintEqualToAnchor(self.superview?.widthAnchor).active = true
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