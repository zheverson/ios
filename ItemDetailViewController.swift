
/* This view controller is presented from collection view, it's purpose is to play video, and let customer see product associated with video.
*/
import UIKit
import AVFoundation

class ItemDetailViewController: AnimationViewController, AnimationViewControllerDelegate {
    
    // init properties
    var contentID:Int
    var thumb: UIImage

    var av:AVPlayer?
    var videoView: VideoView?
    var itemsView: ItemsDisplayView?
    var itemsInfoView: ItemsInfoView?
    
    var creatorName:String?
    var creatorThumb:UIImage?
    let creatorViewData = creatorViewPara()

    var timeline: [CGFloat]!
    
    // MARK: init
    init(contentID: Int, thumb:UIImage, cellFrame: CGRect) {
        self.contentID = contentID
        self.thumb = thumb
        super.init(toFrame: cellFrame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        // instantiate avplayer
        let duration = addAVPlayer()
        
        // add creatorView
        addCreatorView()
        
        // add videoView
        let ratio = self.toFrame.size.height / self.toFrame.size.width
        let videoY = creatorViewData.position.y + creatorViewData.width + 10
        print(videoY)
        let frame = CGRect(x: 0, y: videoY, width: self.view.frame.width, height: self.view.frame.width * ratio)
        videoView = VideoView(frame: frame, av: av!, duration: duration, thumb: self.thumb)
        self.view.addSubview(videoView!)
        
        // add itemsDisplayView
        getItemsData()
        
        // transition animation
        self.animationDelegate = self
        
        // add item info view
        let y = self.itemsView?.nextViewOrigin().y
        itemsInfoView = ItemsInfoView(frame: CGRect(x: 0, y: y! + 40, width: self.view.frame.width, height: 100))
        self.view.addSubview(itemsInfoView!)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func addCreatorView() {
        let thumbView = UIImageView(image: creatorThumb!)
        thumbView.frame = CGRect(origin: creatorViewData.position, size: CGSize(width: creatorViewData.width, height: creatorViewData.width))
        thumbView.cornerize(nil)
        
        let nameLabel = UILabel(frame: CGRect(x: creatorViewData.thumbNameSpace + thumbView.nextViewOrigin().x, y: creatorViewData.position.y, width: 10, height: thumbView.frame.height))
        nameLabel.setText = creatorName!
        self.view.addSubViews([thumbView, nameLabel])
    }
    
    // MARK: AVPlayer
    func addAVPlayer() -> Float {
        let URLString = "http://54.223.65.44:8100/static/video/content/\(self.contentID)/mobile/\(self.contentID)"
        let nsurl = NSURL(string: URLString)
        let asset = AVURLAsset(URL: nsurl!)
        let duration = Float(CMTimeGetSeconds(asset.duration))
        let playerItem = AVPlayerItem(asset: asset)
        av = AVPlayer(playerItem: playerItem)
        AVSync()
        return duration
    }
    
    func AVSync() {
        av!.addPeriodicTimeObserverForInterval(CMTimeMake(1, (av!.currentTime().timescale)), queue: nil) {
            [weak self] time in
            if self != nil {
                let second = CGFloat(CMTimeGetSeconds(time))
                //sync slider value
                self!.videoView!.videoSlider!.value = Float(second)
                
                //sync itemsView speed
                self!.itemsView!.setContentOffset(CGPoint(x: self!.itemsView!.itemViewOffset(second, timeline: self!.timeline), y: 0), animated: true)
                
                //transform image size
                for (index, time) in self!.timeline.enumerate() {
                    if (second - time) < 1 && (second - time > 0) {
                        if index%2 == 0 {
                            let sub = "/name/price"
        
                            let okk = self?.itemsView!.itemsID[index/2][0][0]
                            print(host + "item/\(okk!)" + sub)
                            let data = try? String(contentsOfURL: NSURL(string: host + "item/\(Int(okk!))" + sub)!)
                            let dd = data!.componentsSeparatedByString("&")
                       
                            let price = dd[1]
                            let name = dd[0]
                            
                            self?.itemsInfoView?.name?.setText = name
                            self?.itemsInfoView?.price?.setText = price
               
                            UIView.animateWithDuration(3) {
                                for item in self!.itemsView!.itemsImageView[index/2] {
                                    item.transform = CGAffineTransformMakeScale(1.5, 1.5)
                                }
                            }
                        } else {
                            UIView.animateWithDuration(3) {
                                for item in self!.itemsView!.itemsImageView[(index-1)/2] {
                                    item.transform = CGAffineTransformMakeScale(1, 1)
                                }
                            }
                        }
                        break
                    }
                }
            }
        }
    }
    
    // MARK:get Items Data
    func getItemsData() {
        let videoModelURL = NSURL(string: "http://54.223.65.44:8100/content/\(self.contentID)")
        let item_times = json(videoModelURL!, type: [String:AnyObject]())
        let itemsID = item_times["items"] as! [[[Double]]]
        timeline = item_times["timeline"] as! [CGFloat]
        let itemsDisplayY = videoView?.nextViewOrigin().y
        itemsView = ItemsDisplayView(frame: CGRect(x: 0, y: itemsDisplayY! + 20, width: ScreenSize.width, height: 100), itemsID:itemsID)
        
        self.view.addSubview(itemsView!)
    }
    
    // MARK: transition animation
    func viewToBeDismissed() -> UIView {
        return self.videoView!
    }
    
    func animateDuration() -> NSTimeInterval {
        return 3
    }

    deinit{
        print(3)
    }
}
