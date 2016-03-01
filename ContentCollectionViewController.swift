import UIKit

private let reuseIdentifier = "Cell"

class ContentCollectionViewController: UICollectionViewController, WaterfallLayoutDelegate, viewToBeAnimated {
    
    var Content = Feeds()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Content.getData(host + "user")
    }
    
    // Mark: UICollectionView DataSource Protocol
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Content.feedsData.count
    }
    
    // Cell Model: creator_image, video_image, title, creator_name
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        
        if cell.creator_thumb.image == nil {
            cell.creator_thumb.cornerize(nil)
            cell.video_thumb.cornerize(cell.frame.width/30)
        }
        
        let feed = Content.feedsData[indexPath.item]
        cell.name.text = feed.name
        cell.title.text = feed.title

        let creator_thumb_url = encodeURL(host + "static/image/creator_thumbnail/" + feed.name)
        cell.creator_thumb.startDownload(creator_thumb_url)

        let video_thumb_url = encodeURL(host + "static/image/video_thumbnail/mobile/" + feed.id)
        cell.video_thumb.startDownload(video_thumb_url)
        
        return cell
    }
    
    // cancel cell image download
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (cell as! CollectionViewCell).creator_thumb.cancelDownload()
        (cell as! CollectionViewCell).video_thumb.cancelDownload()
    }

    // Mark: WaterfallLayoutDelegate Protocol
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, ratioForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let width:CGFloat = 375/2
        let ratio = width/(95+(width/Content.feedsData[indexPath.item].ratio))

        return ratio
    }
    
    func collectionViewColumbNum(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> Int {
        return 2
    }
    
    // Mark: Select Cell Segue
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let feed = Content.feedsData[indexPath.item]
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        let image = cell.video_thumb.image

        let cellFrame = cell.video_thumb.convertRect(cell.video_thumb.bounds, toView: nil)
        let svc = ItemDetailViewController(contentID: Int(feed.id)!, thumb: image!, cellFrame: cellFrame)
        svc.creatorName = feed.name
        svc.creatorThumb = cell.creator_thumb.image
        self.presentViewController(svc, animated: true, completion: nil)
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
