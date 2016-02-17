import UIKit

private let reuseIdentifier = "Cell"



class ContentCollectionViewController: UICollectionViewController, WaterfallLayoutDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    var Content = Feeds()
    var host = "http://54.223.65.44:8100/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
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
        
        print(cell.frame.size.height)
        return cell
    }
    // cancel cell image download
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (cell as! CollectionViewCell).creator_thumb.cancelDownload()
        (cell as! CollectionViewCell).video_thumb.cancelDownload()
    }

    // Mark: WaterfallLayoutDelegate Protocol
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, ratioForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Content.feedsData[indexPath.item].ratio
    }
    
    func collectionViewColumbNum(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> Int {
        return 1
    }
    
    // Mark: Select Cell Segue
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let svc = ItemDetailViewController()
        let feed = Content.feedsData[indexPath.item]
        svc.contentID = Int(feed.id)
        svc.ratio = feed.ratio
        self.navigationController?.pushViewController(svc, animated: true)
    }
    
    // Segue Animation
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .Push {
            let transition = Animator()
            return transition
        } else {
            return nil
        }
    }
    
}
