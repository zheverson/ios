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
            let url = Item(id: (self.item?.allColorArray[itemNumber])!).itemImageURL("product")
            itemImage?.startDownload(url)
            
            let newCell = colorCollection.cellForItemAtIndexPath(NSIndexPath(forItem: itemNumber, inSection: 0)) as! colorCell

            UIView.animateWithDuration(3) {
                newCell.colorName.textColor = UIColor(red: 1, green: 215/255, blue: 0, alpha: 1)
            }
        }
    }
    var item:Item!
    
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
        
        getItemDetailInfo()
        itemImageSetup()
        setupTransitionDelegate()
        relatedVideoSetup()
        // like and cart button
        cartButton.startDownloadImage(cartImageURL)

        likeButton.startDownloadImage(likeImageURL)
        
        colorCollectionSetup()
        
        itemSetLabel.setText = "可搭配其它套餐"
        itemSetLabel.font = UIFont(name: font1, size: 15)
        
        relatedVideoLabel.setText = "包含此产品的视频"
        relatedVideoLabel.font = UIFont(name: font1, size: 15)
    }
    
    private func getItemDetailInfo() {
        self.item.getAllColor({
            a, b in
            self.item.allColor = a
            self.item.allColorArray = b
            dispatch_async(dispatch_get_main_queue()){
                self.colorCollection.reloadData()
            }
        })
    }
    
    private func itemImageSetup() {
        itemImageContainerView.heightAnchor.constraintEqualToAnchor(itemImageContainerView.widthAnchor, multiplier: 1/(item?.itemImageRatio!)!).active = true
        
        itemImage = UIImageView()
        itemImageContainerView.addSubview(itemImage!)
        itemImage?.fillInSuperView()
        itemImage?.image = itemImageData
    }
    
    private func colorCollectionSetup(){
        // color view
        colorCollection.dataSource = self
        colorCollection.delegate = self
        let layout = colorCollection.collectionViewLayout as! UICollectionViewFlowLayout
        let itemSize = layout.itemSize
        layout.headerReferenceSize = CGSize(width: (colorCollection.frame.width - itemSize.width)/2, height: colorCollection.frame.height)
        layout.footerReferenceSize = layout.headerReferenceSize
    }
    
    private func updateItemViewInfo() {
        
        self.brandName.setText = (item?.brand)!
        self.itemPrice.setText = "￥\((item?.price)!)"
        self.itemNameLabel.setText = (item?.name)!
    }
    
    private func relatedVideoSetup() {
        self.relatedVideoCollectionView.dataSource = self
        self.relatedVideoCollectionView.delegate = self
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case colorCollection:
            return item.allColorArray.count
        case itemSetCollectionView:
            return 0
        case relatedVideoCollectionView:
            guard let num = item.contents?.feedsData.count else { return 0}
            return num
        default:
            return 0
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case colorCollection:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorCell", forIndexPath: indexPath) as! colorCell
            
            let colorName = item?.allColor[(item?.allColorArray[indexPath.item])!]
            let url = Item(id: item!.allColorArray[indexPath.item]).itemImageURL("color")
            cell.colorImage.startDownload(url)
            cell.colorImage.layer.masksToBounds = true
            cell.colorImage.layer.cornerRadius = cell.colorImage.frame.width/2
            cell.colorName.text = colorName
            cell.colorName.font = colorFont
            return cell
        case relatedVideoCollectionView:
            print(999)
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("relatedVideo", forIndexPath: indexPath) as! ItemRelatedVideoCell
            let content = item.contents?.feedsData[indexPath.item]
            cell.contentImage.startDownload((content!.videoThumbURL()))
            cell.contentTitle.text = content?.title
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch collectionView {
        case relatedVideoCollectionView:
            let height:CGFloat = 60
            let width = height * (item.contents?.feedsData[indexPath.item].thumb_ratio)!
            return CGSize(width: width, height: height + 30)
        case colorCollection:
            let itemSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
            return itemSize
        default:
            print("not possible")
            return CGSizeZero
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        switch scrollView {
        case colorCollection:
            let v = scrollView as! UICollectionView
            let cell = v.cellForItemAtIndexPath(NSIndexPath(forItem: itemNumber, inSection: 0)) as? colorCell
            if cell != nil {
                cell!.colorName.textColor = UIColor.blackColor()
            }
        // get data
        case scrollContainerView:
            guard item.contents == nil else { return }
            item.getContents()
            relatedVideoCollectionView.reloadData()
        default:
            break
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
    
    

    
    
    




