
/* This view controller is presented from collection view, it's purpose is to play video, and let customer see product associated with video.
*/
import UIKit
import AVFoundation

class ItemDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // init properties
    var contentID:Int
    var ratio: CGFloat
    var thumb: UIImage
    
    var av:AVPlayer!
    var videoView: VideoView!
    var itemsView: UIScrollView!
    
    var spaceVideoItem:CGFloat = 40
    
    // itemView frame parameter
    var itemsViewHeight:CGFloat = 100
    let itemsImageHeight:CGFloat = 60
    let itemsInterSpace:CGFloat = 40
    let sameTimeItemSpace: CGFloat = 10
    
    var itemsImageView = [[UIImageView]]()
    
    // data model
    var itemsID: [[[Double]]]!
    var timeline: [CGFloat]!
    
    init(ratio: CGFloat, contentID: Int, thumb:UIImage) {
        self.ratio = ratio
        self.contentID = contentID
        self.thumb = thumb
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitioningDelegate = self
        
        // instantiate avplayer
        let duration = addAVPlayer()
        
        // add videoView
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width/self.ratio)
        videoView = VideoView(frame: frame, av: av, duration: duration, thumb: self.thumb)
        self.view.addSubview(videoView)
        
        // add view controller dismiss button
        let button = UIButton(frame: CGRect(x: 5, y: 55, width: 50, height: 50))
        button.addTarget(self, action: "dismissButton:", forControlEvents: .TouchDown)
        button.backgroundColor = UIColor.redColor()
        self.view.addSubview(button)
        
        // get items data
        getItemsData()
        
        // add item view
        addItemsView()
    }

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
        av.addPeriodicTimeObserverForInterval(CMTimeMake(1, (av.currentTime().timescale)), queue: nil) {
            [weak self] time in
            if self != nil {
                let second = CGFloat(CMTimeGetSeconds(time))
                //sync slider value
                self!.videoView.videoSlider!.value = Float(second)
                
                //sync itemsView speed
                self!.itemsView.setContentOffset(CGPoint(x: self!.itemViewOffset(second), y: 0), animated: true)
                
                //transform image size
                for (index, time) in self!.timeline.enumerate() {
                    if (second - time) < 1 && (second - time > 0) {
                        if index%2 == 0 {
                            UIView.animateWithDuration(3) {
                                for item in self!.itemsImageView[index/2] {
                                    item.transform = CGAffineTransformMakeScale(1.5, 1.5)
                                }
                            }
                        } else {
                            UIView.animateWithDuration(3) {
                                for item in self!.itemsImageView[(index-1)/2] {
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
    
    // Mark:get Items Data
    func getItemsData() {
        let videoModelURL = NSURL(string: "http://54.223.65.44:8100/content/\(self.contentID)")
        let item_times = json(videoModelURL!, type: [String:AnyObject]())
        itemsID = item_times["items"] as! [[[Double]]]
        timeline = item_times["timeline"] as! [CGFloat]
    }

    // Add ItemsView()
    func addItemsView() {
        let width = self.view.frame.width
        let Height = self.videoView.frame.height
        itemsView = UIScrollView(frame: CGRect(x: 0, y: Height + spaceVideoItem, width: width, height: 100))
        var xAxis:CGFloat = width
        
        for (itemindex, items) in itemsID.enumerate() {
            for (index, item) in items.enumerate() {
                
                let itemWidth = itemsImageHeight * CGFloat(item[1])
                let nsurl = NSURL(string: "http://54.223.65.44:8100/static/image/item_thumbnail/" + String(Int(item[0])))
                
                let view = UIImageView()
                if index == 0 {
                    itemsImageView.append([view])
                } else {
                    xAxis = xAxis - (self.itemsInterSpace - self.sameTimeItemSpace)
                    itemsImageView[itemindex].append(view)
                }
                
                view.frame = CGRect(x: xAxis, y: 10, width:itemWidth , height: itemsImageHeight)
                view.startDownload(nsurl!)
                xAxis += (self.itemsInterSpace + itemWidth)
                self.itemsView.addSubview(view)
            }
        }
        itemsView.contentSize = CGSize(width: xAxis, height: itemsViewHeight)
        self.view.addSubview(itemsView)
    }
    
    // map video time to itemsview offset
    func itemViewOffset(second:CGFloat) -> CGFloat {
        let item1Width = itemsImageHeight * CGFloat(self.itemsID[0][0][1])
        var itemOffset = item1Width + itemsInterSpace/2 + self.view.frame.width/2
        if second < self.timeline[2] {
            return itemOffset * second/(self.timeline[2])
            
        } else if second > self.timeline[self.timeline.count - 1] {
            return 1.5
            
        } else {
            for index in 2.stride(through: self.timeline.count-2, by: 2) {
                if second >= self.timeline[index] && second < self.timeline[index+2] {
                    
                    let itemWidth = itemGroupWidth(index/2)
                    
                    for i in 4.stride(through: index, by: 2) {
                        itemOffset = itemOffset + itemGroupWidth((i-2)/2) + itemsInterSpace
                    }
                    let secondPercent = (second-self.timeline[index])/(self.timeline[index+2]-self.timeline[index])
                  
                    return itemOffset + (itemWidth + itemsInterSpace) * secondPercent
                }
            }
        }
        print("not possible")
        return 1
    }
    
    func itemGroupWidth(index: Int) -> CGFloat {
        var width:CGFloat = 0
        for item in self.itemsID[index]{
            width += itemsImageHeight * CGFloat(item[1])
        }
        width += self.sameTimeItemSpace * CGFloat((self.itemsID[index].count - 1))
        return width
    }
    
    func dismissButton(button: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = Animator()
        return animator
    }
}
