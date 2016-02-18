
import UIKit

class WaterfallLayout: UICollectionViewFlowLayout {
    
    var itemLayoutAttributesOfSection = [[UICollectionViewLayoutAttributes]]()
    var columnNumber = 2
    var columnPosition = [CGFloat]()
    var ratio:CGFloat = 1
    
    override func prepareLayout() {
        
        let delegate = self.collectionView?.delegate as! WaterfallLayoutDelegate
        
        self.columnNumber = delegate.collectionViewColumbNum(self.collectionView!, layout: self) ?? self.columnNumber
        self.columnPosition.appendContentsOf(Array(count: self.columnNumber, repeatedValue: 0))
        self.itemLayoutAttributesOfSection.appendContentsOf(Array(count: self.columnNumber, repeatedValue: [UICollectionViewLayoutAttributes]()))
        
        let width = self.collectionView?.bounds.width
        
        for i in 0..<self.collectionView!.numberOfSections() {
            
            self.minimumInteritemSpacing = delegate.collectionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAtIndex: i) ?? self.minimumInteritemSpacing
            
            self.minimumLineSpacing = delegate.collectionView?(self.collectionView!, layout: self, minimumLineSpacingForSectionAtIndex: i) ?? self.minimumLineSpacing
            
            self.sectionInset = delegate.collectionView?(self.collectionView!, layout: self, insetForSectionAtIndex: i) ?? self.sectionInset
            
            self.headerReferenceSize = delegate.collectionView?(self.collectionView!, layout: self, referenceSizeForHeaderInSection: i) ?? self.headerReferenceSize
            
            self.columnPosition = self.columnPosition.map({$0 + self.sectionInset.top + self.headerReferenceSize.height})
            
            let itemWidth = (width! - self.sectionInset.left - self.sectionInset.right - self.minimumInteritemSpacing * CGFloat(self.columnNumber - 1)) / CGFloat(self.columnNumber)
            
            for j in 0..<self.collectionView!.numberOfItemsInSection(i) {
                
                let indexPath = NSIndexPath(forItem: j, inSection: i)
                
                let layoutAttribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                
                self.ratio = delegate.collectionView(self.collectionView!, layout: self, ratioForItemAtIndexPath: indexPath) ?? self.ratio
                
                let itemHeight = itemWidth / ratio
                layoutAttribute.frame.size = CGSize(width: itemWidth, height: itemHeight)
                let low = self.columnPosition.indexOf(self.columnPosition.minElement()!)!
                layoutAttribute.frame.origin.x = self.sectionInset.left + (itemWidth + self.minimumInteritemSpacing) * CGFloat(low)
                layoutAttribute.frame.origin.y = self.columnPosition.minElement()! + self.minimumLineSpacing
                
                self.columnPosition[low] += itemHeight + self.minimumLineSpacing
                itemLayoutAttributesOfSection[i].append(layoutAttribute)
            }
            
            self.footerReferenceSize = delegate.collectionView?(self.collectionView!, layout: self, referenceSizeForFooterInSection: i) ?? self.footerReferenceSize
            
            self.columnPosition = Array(count: self.columnNumber, repeatedValue: self.columnPosition.maxElement()! + self.footerReferenceSize.height + self.sectionInset.bottom)
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        
        return CGSize(width: (self.collectionView?.bounds.width)!, height: self.columnPosition[0])
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var attrs = [UICollectionViewLayoutAttributes]()
        
        for i in 0..<self.collectionView!.numberOfSections() {
            for j in 0..<self.collectionView!.numberOfItemsInSection(i) {
                if CGRectIntersectsRect(rect, itemLayoutAttributesOfSection[i][j].frame) {
                    attrs.append(itemLayoutAttributesOfSection[i][j])
                }
            }
        }
        
        return attrs
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        return itemLayoutAttributesOfSection[indexPath.section][indexPath.item]
    }
}


@objc protocol WaterfallLayoutDelegate: class, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, ratioForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat
    
    func collectionViewColumbNum(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> Int
}
