import UIKit

class ItemDetailsViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var itemImageData:UIImage?
    var itemImage: UIImageView?
        
    @IBOutlet weak var scrollContainerView: UIScrollView!
    
    @IBOutlet weak var itemImageContainerView: UIView!
    
    @IBOutlet weak var itemPrice: UILabel!
    
    @IBOutlet weak var imageArrowView: shadowArrowView!
    
    @IBOutlet weak var brandName: UILabel!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var colorCollection: UICollectionView!
    
    @IBOutlet weak var cartButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var itemSpecTextView: UITextView!
    
    @IBOutlet weak var itemSetLabel: UILabel!
    
    @IBOutlet weak var itemSetCollectionView: UICollectionView!
    
    @IBOutlet weak var relatedVideoLabel: UILabel!
    
    @IBOutlet weak var relatedVideoCollectionView: UICollectionView!
    
    var itemVCTransition: ViewMapTransition!
 
    var cellFrame:CGRect?

    var itemNumber = 0 {
        didSet {

            colorCollection.scrollToItemAtIndexPath(NSIndexPath(forItem: itemNumber, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: true)
            
            itemImage!.startDownload(NSURL(string: "http://54.223.65.44:8100/static/image/item/\((self.item?.allColorArray[itemNumber])!)/product")!)
            
            let newCell = colorCollection.cellForItemAtIndexPath(NSIndexPath(forItem: itemNumber, inSection: 0)) as! colorCell

            UIView.animateWithDuration(3) {
                newCell.colorName.textColor = UIColor(red: 1, green: 215/255, blue: 0, alpha: 1)
            }
        }
    }
    var item:Item?
    
    let colorFont = UIFont(name: "IowanOldStyle-Roman", size: 11)
    let brandFont = UIFont(name: "IowanOldStyle-Bold", size: 25)
    let itemNameFont = UIFont(name: font1, size: 15)
    let priceFont = UIFont(name: "IowanOldStyle-Bold", size: 20)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollContainerView.delegate = self
        // item price & name
        self.itemNameLabel.font = self.itemNameFont
        self.brandName.font = self.brandFont
        self.itemPrice.font = self.priceFont
        updateItemViewInfo()
        
        self.item?.getAllColor({
            dispatch_async(dispatch_get_main_queue()){
                self.colorCollection.reloadData()
            }
        })
        
       itemImageContainerView.heightAnchor.constraintEqualToAnchor(itemImageContainerView.widthAnchor, multiplier: 1/(item?.itemImageRatio!)!).active = true
        
        itemImage = UIImageView()
        itemImageContainerView.addSubview(itemImage!)
        itemImage?.fillInSuperView()
        itemImage?.image = itemImageData
        setupTransitionDelegate()
        
        // like and cart button
        cartButton.startDownloadImage(NSURL(string: "http://54.223.65.44:8100/static/image/util/cart")!)

        likeButton.startDownloadImage(NSURL(string: "http://54.223.65.44:8100/static/image/util/like")!)
        
        // color view
        colorCollection.dataSource = self
        colorCollection.delegate = self
        let layout = colorCollection.collectionViewLayout as! UICollectionViewFlowLayout
        let itemSize = layout.itemSize
        layout.headerReferenceSize = CGSize(width: (colorCollection.frame.width - itemSize.width)/2, height: colorCollection.frame.height)
        layout.footerReferenceSize = layout.headerReferenceSize
        
        itemSetLabel.setText = "可搭配其它套餐"
        itemSetLabel.font = UIFont(name: font1, size: 15)
        
        relatedVideoLabel.setText = "包含此产品的视频"
        relatedVideoLabel.font = UIFont(name: font1, size: 15)
    }
    
    private func updateItemViewInfo() {
        
        self.brandName.setText = (item?.brand)!
        self.itemPrice.setText = "￥\((item?.price)!)"
        self.itemNameLabel.setText = (item?.name)!
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case colorCollection:
            return (item?.allColorArray.count)!
        case itemSetCollectionView:
            return 0
        case relatedVideoCollectionView:
            return 0
        default:
            return 0
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case colorCollection:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorCell", forIndexPath: indexPath) as! colorCell
            
            
            let colorName = item?.allColor[(item?.allColorArray[indexPath.item])!]
            cell.colorImage.startDownload(NSURL(string: "http://54.223.65.44:8100/static/image/item/\(item!.allColorArray[indexPath.item])/color")!)
            cell.colorImage.layer.masksToBounds = true
            cell.colorImage.layer.cornerRadius = cell.colorImage.frame.width/2
            cell.colorName.text = colorName
            cell.colorName.font = colorFont
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch collectionView {
        case colorCollection:
            switch kind {
            case UICollectionElementKindSectionHeader:
                let v = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "colorHeader", forIndexPath: indexPath)
                
                return v
            default:
                let v = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "colorFooter", forIndexPath: indexPath)
                
                return v
            }
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch collectionView{
        case colorCollection:
            let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: itemNumber, inSection: 0)) as! colorCell
            cell.colorName.textColor = UIColor.blackColor()
            itemNumber = indexPath.item
        default:
            break
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        if scrollView === colorCollection {
            let v = scrollView as! UICollectionView
            let cell = v.cellForItemAtIndexPath(NSIndexPath(forItem: itemNumber, inSection: 0)) as? colorCell
            if cell != nil {
                cell!.colorName.textColor = UIColor.blackColor()
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
        guard scrollView === scrollContainerView else {return }
        guard scrollView.tracking == true else { return }
        
        if scrollView.contentOffset.y < 0 && !(itemVCTransition.didStart) {
            
            self.dismissViewControllerAnimated(true, completion: nil)
            itemVCTransition.didStart = true
            
        } else if itemVCTransition.didStart {
            
            itemVCTransition?.update(abs(scrollView.contentOffset.y) / 100)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if scrollView === self.colorCollection {
            if decelerate {return}
            self.scrollViewDidEndDecelerating(scrollView)
        } else if scrollView === scrollContainerView {

            if itemVCTransition.didStart {
                itemVCTransition?.complete(abs(scrollView.contentOffset.y) / 100, threshold: 0.5)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if scrollView === colorCollection {
            let v = scrollView as! UICollectionView
            let inter = (v.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing
            let y = v.frame.height/2 + v.frame.origin.y
            let x = v.frame.width/2 + v.frame.origin.x + inter/2
            
            let point = scrollView.convertPoint(CGPoint(x: x, y: y), fromView: view)
            
            if let itemPath = v.indexPathForItemAtPoint(point) ?? v.indexPathForItemAtPoint(CGPoint(x: point.x - inter, y: point.y)) {
            
            itemNumber = itemPath.item
        }
        }
    }
    
    func setupTransitionDelegate() {
        itemVCTransition = ViewMapTransition(animateView: itemImage!,toFrame: self.presentFrame(), duration: 1.5)
        self.transitioningDelegate = itemVCTransition
    }
    
    func presentFrame() -> CGRect {
    
        var origin = itemImageContainerView.convertPoint(CGPointZero, toView: view)
        let width = itemImageContainerView.frame.width
        
        origin.x = (view.frame.width - itemImageContainerView.frame.width)/2
        let height = itemImageContainerView.frame.width / (item?.itemImageRatio!)!
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
}
    
    

    
    
    




