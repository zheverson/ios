import UIKit

private let reuseIdentifier = "Cell"


class ContentCollectionViewController: UICollectionViewController, WaterfallLayoutDelegate, presentingVCDeleage{
    
    var contents = Feeds()
    let layoutPara = layoutStruct()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contents.getData(host + "user")
    }
    
    // Mark: UICollectionView DataSource Protocol
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.feedsData.count
    }
    
    // Cell Model: creator_image, video_image, title, creator_name
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        
        if cell.creator_thumb.image == nil {
            cell.creator_thumb.cornerize(nil)
        }
        
        let feed = contents.feedsData[indexPath.item]
        cell.name.text = feed.name
        cell.title.text = feed.title
        cell.title.font = contentTitleFont
        cell.name.font = UIFont(name: font1, size: nameSize)

        let creator_thumb_url = encodeURL(host + "static/image/creator_thumbnail/" + feed.name)
        cell.creator_thumb.startDownload(creator_thumb_url)

        let video_thumb_url = encodeURL(host + "static/image/video_thumbnail/mobile/\(feed.id)" )
        cell.video_thumb.startDownload(video_thumb_url)
        
        cell.cornerize(4)
        return cell
    }
    
    // cancel cell image download
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (cell as! CollectionViewCell).creator_thumb.cancelDownload()
        (cell as! CollectionViewCell).video_thumb.cancelDownload()
    }

    // Mark: WaterfallLayoutDelegate Protocol
    // width / height
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, ratioForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let l = collectionViewLayout as! WaterfallLayout
        let mit = l.minimumInteritemSpacing
        let left = l.sectionInset.left
        let right = l.sectionInset.right
        let width = (self.collectionView!.frame.width - mit - left - right) / 2
        let labelWidth = width - 16
        let labelHeight = contents.feedsData[indexPath.item].title.heightForText(labelWidth, font: contentTitleFont!)
        
        let height = labelHeight + width/contents.feedsData[indexPath.item].thumb_ratio + 56
        
        return width / height
    }
    
    func  collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return layoutPara.itemSpace
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return layoutPara.sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return layoutPara.lineSpace
    }
    
    func collectionViewColumbNum(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> Int {
        return 2
    }
    
    // Mark: Select Cell Segue
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let feed = contents.feedsData[indexPath.item]
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        guard let creator_image = cell.creator_thumb.image, image = cell.video_thumb.image  else {
            self.networkAlertShow()
            return
        }
        
        let svc = self.storyboard?.instantiateViewControllerWithIdentifier("contentDetail") as! ContentDetailViewController
   
        svc.videocontent = feed
         
        svc.thumb = image
        
        svc.creatorName = feed.name
        
        svc.creatorThumb = creator_image
  
        self.presentViewController(svc, animated: true){

        }
    }
    

    
    func viewToBeAnimated() -> UIView {
        let path = collectionView?.indexPathsForSelectedItems()
        let cell = (self.collectionView?.cellForItemAtIndexPath(path![0]))! as! CollectionViewCell
        let image = cell.video_thumb.image
        let v = UIImageView(image: image)
        v.frame = cell.video_thumb.convertRect(cell.video_thumb.bounds, toView: nil)
        return v
    }
}
