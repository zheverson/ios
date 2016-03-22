 
 /* This view controller is presented from collection view, it's purpose is to play video, and let customer see product associated with video.
 */
 import UIKit
 import AVFoundation
 import AVKit
 
 public var start:CFAbsoluteTime = 0
 
 class ContentDetailViewController:AnimationViewController, presentingVCDeleage, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, presentedVCDelegate {
    
    // MARK: view property
    var creatorThumb:UIImage?
    
    @IBOutlet weak var creatorImage: UIImageView!
    
    var creatorName:String?
    
    @IBOutlet weak var creatorNameLabel: UILabel!
    
    @IBOutlet weak var videoContainerView: UIView!
    
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    
    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var cartImage: UIImageView!
    
    @IBOutlet weak var itemDataView: itemsInfoView!
    
    private var viewAnimate:UIView?
    
    // MARK: data property
    var cellHeight:CGFloat = 70
    var startOffset:CGFloat = 100
    var interSectionSpace:CGFloat = 20
    
    var thumb: UIImage?
    
    var videocontent:videoContent?
    
    private var AVObserver:AnyObject?
    private var player:AVPlayer?
    var userRate:Bool = false
    
    private var starSection:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pan = UIPanDirectionGestureRecognizer(direction: .UpToDown,target: self, action: "aaa:")
        self.view.addGestureRecognizer(pan)
       
        fillCreatorView()
        videocontent?.getItems()
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
        self.animationDelegate = self
        
        let ratio = (toFrame?.width)!/(toFrame?.height)!

        videoContainerView.heightAnchor.constraintEqualToAnchor(videoContainerView.widthAnchor, multiplier: 1/ratio).active = true
        
        itemsCollectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "normalheader")
        itemsCollectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "normalfooter")
        
        likeImage.startDownload(NSURL(string: "http://54.223.65.44:8100/static/image/util/like")!)
        cartImage.startDownload(NSURL(string: "http://54.223.65.44:8100/static/image/util/cart")!)

    }
    
    @objc private func aaa(pan:UIPanGestureRecognizer) {
        switch pan.state {
        case .Began:
            self.dismissBegin()
        case .Changed:
            // calculate user gesture input
            let v = pan.view
            let translation = pan.translationInView(v)
            self.percent = fabs(translation.y*2/(v?.bounds.size.height)!)
            self.dismissChanged()
        case .Ended:
            self.dismissComplete()
        default: break
        }
    }
    
    // MARK: item collection display view
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (videocontent?.items.count)!
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (videocontent?.items[section].count)!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("itemImage", forIndexPath: indexPath) as! ItemCollectionViewCell
        let itemID = ((videocontent?.items[indexPath.section][indexPath.item])?.id)!
        let url = NSURL(string: host + "static/image/item/\(itemID)/product")
        cell.itemImage.startDownload(url!)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let v = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "normalheader", forIndexPath: indexPath)
            return v
        } else {
            let v = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "normalfooter", forIndexPath: indexPath)
            return v
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: cellHeight * (videocontent!.items[indexPath.section][indexPath.item]).itemImageRatio!, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return collectionView.bounds.size
        } else { return CGSizeZero }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == (videocontent?.items.count)! - 1 {
            return collectionView.bounds.size
        } else { return CGSize(width: interSectionSpace, height: collectionView.frame.height) }
    }
    
    // MARK: video view segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "videoView" {
            let vc = segue.destinationViewController as! VideoViewController
            player = AVPlayer(URL: NSURL(string: host + "static/video/content/\((self.videocontent?.id)!)/mobile/\((self.videocontent?.id)!)")!)
            vc.player = player
            vc.thumbImage = thumb
            
            /* How collectionView respond to time in video view.。
            每秒对应一个新的section，如果出现第一个section，那么animate，并且把animate的Section cache上，如果新的section和已有的section不一样，那么证明要animate新的了，这时候cellforindexatpath可能是nil，因此只有真正cell不是nil，并且animate了以后，换cache的section值，并把上一个deanimate
            */
            
            // MARK: collection view respond to video view
            self.AVObserver = player!.addPeriodicTimeObserverForInterval(CMTimeMake(1, (player!.currentTime().timescale)), queue: nil) {
                [weak self] time in
                guard self != nil else { return }
                let second = CGFloat(CMTimeGetSeconds(time))
                print(second)
                self!.itemsCollectionView!.setContentOffset(CGPoint(x: self!.itemViewOffset(second), y: 0), animated: true)
                
                let sectionIndex = self?.getSecondIndex(second)
                
                guard sectionIndex != self?.starSection else {
                    return
                }
                
                outif: if sectionIndex >= 0 {
                    guard let itemFrames = self!.animateSection(sectionIndex!) else { break outif }
                    self?.itemDataView.updateItems((self?.videocontent?.items[sectionIndex!])!, fromFrame: itemFrames)
                    
                    if self?.starSection != nil {
                        self?.animateSection((self?.starSection)!)
                    }
                    self?.starSection = sectionIndex
                    
                } else {
                    if self?.starSection != nil {
                        self?.animateSection(self!.starSection!)
                        self?.starSection = nil
                    }
                }
            }
        } // AV Observer block complete
    }
    
    private func animateSection(sectionNumber:Int) -> [CGRect]? {
        let sectionItemCount = self.videocontent?.items[sectionNumber].count
        var itemInfoFrame = [CGRect]()
        
        for itemIndex in 0..<sectionItemCount! {
            if let cell = self.itemsCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: itemIndex, inSection: sectionNumber)) {
                itemInfoFrame.append(cell.convertRect(cell.bounds, toView: nil))
                UIView.animateWithDuration(3){
                    if CGAffineTransformIsIdentity((cell.transform)) {
                        cell.transform = CGAffineTransformMakeScale(1.5, 1.5)
                    } else {
                        cell.transform = CGAffineTransformIdentity
                    }
                }
            } else {
                return nil
            }
        }
        return itemInfoFrame
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if !CGAffineTransformIsIdentity(cell.transform){
            cell.transform = CGAffineTransformIdentity
        }
    }
    
    private func itemViewOffset(second:CGFloat) -> CGFloat {
        
        let flowLayout = itemsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let sectionWidth = flowLayout.lengthForSectionAtIndex(0)
        let viewOffset0 = startOffset + sectionWidth - itemsCollectionView.frame.width
        
        guard second > videocontent!.timeline![2] else {
            return viewOffset0 * second/(videocontent!.timeline![2])
        }
        let index = getSecondIndex(second)
        
        return viewOffset0 + cumulativeOffset(index) + nowOffset(index, second: second)
    }
    
    private func getSecondIndex(second:CGFloat) -> Int {
        guard second >= videocontent!.timeline![0] else {
            return -1
        }
        
        for i in 0.stride(to: (videocontent!.timeline?.count)! - 2, by: 2) {
            if case videocontent!.timeline![i]...videocontent!.timeline![i+2] = second {
                return i/2
            }
        }
        return -2
    }
    
    private func cumulativeOffset(index:Int) -> CGFloat {
        let flowLayout = itemsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        var cum:CGFloat = 0
        for i in 1..<index {
            let sectionWidth = flowLayout.lengthForSectionAtIndex(i)
            cum += sectionWidth
        }
        return cum
    }
    
    private func nowOffset(index:Int, second:CGFloat) -> CGFloat {
        guard index > 0 else { return 0 }
        let flowLayout = itemsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let sectionWidth = flowLayout.lengthForSectionAtIndex(index)
        return sectionWidth * (second - videocontent!.timeline![index*2]) / (videocontent!.timeline![index*2+2] - videocontent!.timeline![index*2])
    }
    
    // MARK: top most creator view
    private func fillCreatorView() {
        creatorImage.image = creatorThumb
        creatorImage.cornerize(nil)
        creatorNameLabel.setText = creatorName!
    }
    
    // MARK: dismiss transition animation
    func viewToBeDismissed() -> UIView {
        let v = videoContainerView.subviews[0]

        return v
    }
    
    func presentFrame() -> CGRect {
        let point = videoContainerView.frame.origin
        let width = view.frame.width
  
        let height = width * (toFrame?.height)!/(toFrame?.width)!
        return CGRect(origin: point, size: CGSize(width: width, height: height))
    }
    
    // MARK: present transition animation
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let vcc = self.storyboard!.instantiateViewControllerWithIdentifier("abc") as! ItemDetailsViewController
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ItemCollectionViewCell
        
        let image = cell.itemImage.image
        let u = UIImageView(image:image)
        let frame = cell.itemImage.convertRect(cell.itemImage.bounds, toView: nil)
        u.frame = frame
        viewAnimate = u
        
        vcc.item = (videocontent?.items[indexPath.section][indexPath.item])!
   
        vcc.toFrame = frame
        
        vcc.itemImageData = image
        
        if player?.rate == 1 {
            player?.pause()
            userRate = true
        }
        self.presentViewController(vcc, animated: true,completion: nil)
    }
    
    func dismissAnimatonComplete() {
        if userRate == true {
            player?.play()
            userRate = false
        }
    }
    
    func viewToBeAnimated() -> UIView {
        return viewAnimate!
    }
    deinit {
        player?.removeTimeObserver(self.AVObserver!)
        print("content detail")
    }
 }
