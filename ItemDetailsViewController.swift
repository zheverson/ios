
import UIKit

class ItemDetailsViewController: AnimationViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, presentedVCDelegate {
    
    var itemImageData:UIImage?
    var itemImage: UIImageView?
    
    @IBOutlet weak var itemImageContainerView: UIView!
    
    @IBOutlet weak var itemPrice: UILabel!
    
    @IBOutlet weak var imageArrowView: shadowArrowView!
    
    @IBOutlet weak var brandName: UILabel!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var colorCollection: UICollectionView!
    
    @IBOutlet weak var cartButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    var cellFrame:CGRect?
    
    var residualHeight:CGFloat {
        get {
            return imageArrowView.frame.height - itemImageContainerView.frame.height
        }
    }
    var itemNumber = 0 {
        
        didSet {

            colorCollection.scrollToItemAtIndexPath(NSIndexPath(forItem: itemNumber, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: true)
            
            let colorNumber = color![itemNumber].componentsSeparatedByString(",")[1]
            
            itemImage!.startDownload(NSURL(string: "http://54.223.65.44:8100/static/image/item/\(itemID!)/detail/item/\(colorNumber)")!)
            
            let newCell = colorCollection.cellForItemAtIndexPath(NSIndexPath(forItem: itemNumber, inSection: 0)) as! colorCell

       
            UIView.animateWithDuration(3) {
                
                newCell.colorName.textColor = UIColor(red: 1, green: 215/255, blue: 0, alpha: 1)
            }
        }
    }
    
    private var color:[String]? {
        didSet {
            self.colorCollection.reloadData()
        }
    }
    
    var itemID:Int?
    
    var ratio:CGFloat?
    
    let colorFont = UIFont(name: "IowanOldStyle-Roman", size: 11)
    let brandFont = UIFont(name: "IowanOldStyle-Bold", size: 25)
    let itemNameFont = font1
    let priceFont = font1

    override func viewDidLoad() {
        super.viewDidLoad()
   
        self.animationDelegate = self

        // item price & name
        self.itemNameLabel.font = self.itemNameFont
        self.brandName.font = self.brandFont
        self.itemPrice.font = self.priceFont
        getItemInfo()
        
        imageArrowView.heightAnchor.constraintEqualToAnchor(itemImageContainerView.widthAnchor, multiplier: ratio!, constant: residualHeight).active = true
        itemImage = UIImageView()
        itemImageContainerView.addSubview(itemImage!)
        itemImage?.fillInSuperView()
        itemImage?.image = itemImageData
        
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
    }
    
    private func getItemInfo() {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(NSURL(string: "http://54.223.65.44:8100/item/\(itemID!)/name/price/color/brand")!) {
            data, response, error in
            let ss = String(data: data!, encoding: NSUTF8StringEncoding)
            let dd = ss!.componentsSeparatedByString("&#")
            let px = dd[1]
            let name = dd[0]
            let brand = dd[3]
            self.color = dd[2].componentsSeparatedByString(";")
            self.brandName.setText = brand
            self.itemPrice.setText = "￥" + px
            self.itemNameLabel.setText = name
        }
        task.resume()
    }

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
  
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorCell", forIndexPath: indexPath) as! colorCell
        let info = color![indexPath.item].componentsSeparatedByString(",")
        let colorNumber = info[1]
        let colorName = info[0]
        cell.colorImage.startDownload(NSURL(string: "http://54.223.65.44:8100/static/image/item/\(itemID!)/detail/color/\(colorNumber)")!)
        cell.colorImage.layer.masksToBounds = true
        cell.colorImage.layer.cornerRadius = cell.colorImage.frame.width/2
        cell.colorName.text = colorName
        cell.colorName.font = colorFont
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let v = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "colorHeader", forIndexPath: indexPath)
    
               return v
        default:
            let v = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "colorFooter", forIndexPath: indexPath)

            return v
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard color != nil else { return 0}
        return (color?.count)!
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {return}
        self.scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
   
        let v = scrollView as! UICollectionView
        let inter = (v.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing
        let y = v.frame.height/2 + v.frame.origin.y
        let x = v.frame.width/2 + v.frame.origin.x + inter/2
        
        let point = scrollView.convertPoint(CGPoint(x: x, y: y), fromView: view)
        
        let itemPath = v.indexPathForItemAtPoint(point) ?? v.indexPathForItemAtPoint(CGPoint(x: point.x - inter, y: point.y))
 
        itemNumber = (itemPath?.item)!
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: itemNumber, inSection: 0)) as! colorCell
        cell.colorName.textColor = UIColor.blackColor()
        itemNumber = indexPath.item
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        let cell = (scrollView as! UICollectionView).cellForItemAtIndexPath(NSIndexPath(forItem: itemNumber, inSection: 0)) as? colorCell
        if cell != nil {
            cell!.colorName.textColor = UIColor.blackColor()
        }
    }
    
    // MARK: dismiss Animation
    func viewToBeDismissed() -> UIView {
        return itemImage!
    }
    
    override func presentToFrame() -> CGRect {
        let origin = itemImageContainerView.convertPoint(CGPointZero, toView: view)
        let width = itemImageContainerView.frame.width
        let height = itemImageContainerView.frame.width * ratio!
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
}
    
    

    
    
    




