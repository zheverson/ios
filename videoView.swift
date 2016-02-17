
import UIKit
import AVFoundation

class videoView: UIView {
    
    var av: AVPlayer?
    
    var videoSlider: UISlider?
    
    var itemView: UIScrollView!
    
    let itemViewHeight:CGFloat = 100
    
    let itemVideoInterSpace:CGFloat = 20
    
    let itemImageHeight:CGFloat = 60
    
    let itemInterSpace:CGFloat = 40
    
    let sameTimeItemSpace: CGFloat = 10
    
    var itemsID = [[[Double]]]()
    
    var itemsImage = [[UIImageView]]()
    
    var timeline = [CGFloat]()
    
    init(frame: CGRect, url: String, itemsID:[[[Double]]], timeline: [CGFloat]) {
        super.init(frame: frame)
        let url = NSURL(string: url)
        self.itemsID = itemsID
        self.timeline = timeline
        let tapGesture = UITapGestureRecognizer(target: self, action: "videoViewTapped")
        self.addGestureRecognizer(tapGesture)
        
        AVAssetConfig(url!)
        print(2)
        addItemView()
        print(3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //time observer for video
    func AVAssetConfig(url: NSURL) {
        
        let asset = AVURLAsset(URL: url)
        let duration = asset.duration
        let playerItem = AVPlayerItem(asset: asset)
        av = AVPlayer(playerItem: playerItem)
        
        av?.addPeriodicTimeObserverForInterval(CMTimeMake(1, (av?.currentTime().timescale)!), queue: nil) {
            time in
            
            let second = CGFloat(CMTimeGetSeconds(time))
            //sync slider value
            self.videoSlider!.value = Float(second)
            
            print(second)
            
            self.itemView.setContentOffset(CGPoint(x: self.itemViewOffset(second), y: 0), animated: true)
            
            for (index, time) in self.timeline.enumerate() {
                if (second - time) < 1 && (second - time > 0) {
                    if index%2 == 0 {
                        UIView.animateWithDuration(3) {
                            for item in self.itemsImage[index/2] {
                                item.transform = CGAffineTransformMakeScale(1.5, 1.5)
                            }
                        }
                    } else {
                        UIView.animateWithDuration(3) {
                            for item in self.itemsImage[(index-1)/2] {
                                item.transform = CGAffineTransformMakeScale(1, 1)
                            }
                        }
                    }
                    break
                }
            }
        }
        addAVLayer()
        addSliderToVideoView(Float(CMTimeGetSeconds(duration)))
    }
    
    //video slider
    func addSliderToVideoView(max: Float) {
        let width = self.frame.width
        let height = self.frame.height
        videoSlider = UISlider(frame: CGRect(x: 20, y: height - itemViewHeight - itemVideoInterSpace-20, width: width-40, height: 20))
        
        videoSlider!.maximumValue = max
        videoSlider!.minimumValue = 0
        videoSlider?.addTarget(self, action: "sliderTapped:", forControlEvents:.ValueChanged )
        videoSlider?.alpha = 0
        self.addSubview(videoSlider!)
    }
    
    //add avlayer
    func addAVLayer() {
        let avlayer = AVPlayerLayer(player: av)
        avlayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - itemViewHeight - itemVideoInterSpace)
        self.layer.addSublayer(avlayer)
    }
    
    func videoViewTapped() {
        if av?.rate == 0 {
            av?.play()
            UIView.animateWithDuration(0.5) {
                self.videoSlider?.alpha = 0
            }
        } else if av?.rate == 1 {
            av?.pause()
            UIView.animateWithDuration(0.5) {
                self.videoSlider?.alpha = 1
            }
        }
    }
    
    func sliderTapped(slider: UISlider) {
        let cmtime = CMTimeMakeWithSeconds(Double(slider.value), (av?.currentTime().timescale)!)
        av?.seekToTime(cmtime)
    }
    
    func addItemView() {
        let width = self.frame.width
        let Height = self.frame.height
        
        itemView = UIScrollView(frame: CGRect(x: 0, y: Height - itemViewHeight, width: width, height: itemViewHeight))
        var xAxis:CGFloat = width
        
        
        for (itemindex, items) in self.itemsID.enumerate() {
            for (index, item) in items.enumerate() {
                print(itemindex)
                
                let itemWidth = itemImageHeight * CGFloat(item[1])
                let nsurl = NSURL(string: "http://54.223.65.44:8100/static/image/item_thumbnail/" + String(Int(item[0])))
                
                let view = UIImageView()
                
                if index == 0 {
                    itemsImage.append([view])
                } else {
                    xAxis = xAxis - (self.itemInterSpace - self.sameTimeItemSpace)
                    itemsImage[itemindex].append(view)
                }
                
                view.frame = CGRect(x: xAxis, y: 10, width:itemWidth , height: itemImageHeight)
                view.image = UIImage(data: NSData(contentsOfURL: nsurl!)!)
                xAxis += (self.itemInterSpace + itemWidth)
                itemView.addSubview(view)
            }
        }
        itemView.contentSize = CGSize(width: xAxis, height: itemViewHeight)
        self.addSubview(itemView)
    }
    
    func itemViewOffset(second:CGFloat) -> CGFloat {
        let item1Width = itemImageHeight * CGFloat(self.itemsID[0][0][1])
        var itemOffset = item1Width + itemInterSpace/2 + self.frame.width/2
        if second < self.timeline[2] {
            return itemOffset * second/(self.timeline[2])
            
        } else if second > self.timeline[self.timeline.count - 1] {
            return 1.5
            
        } else {
            for index in 2.stride(through: self.timeline.count-2, by: 2) {
                if second >= self.timeline[index] && second < self.timeline[index+2] {
                    
                    let itemWidth = itemGroupWidth(index/2)
                    
                    for i in 4.stride(through: index, by: 2) {
                        itemOffset = itemOffset + itemGroupWidth((i-2)/2) + itemInterSpace
                    }
                    
                    print(itemOffset)
                    let secondPercent = (second-self.timeline[index])/(self.timeline[index+2]-self.timeline[index])
                    print(secondPercent)
                    
                    return itemOffset + (itemWidth + itemInterSpace) * secondPercent
                }
            }
        }
        print("not possible")
        return 1
    }
    
    func itemGroupWidth(index: Int) -> CGFloat {
        var width:CGFloat = 0
        for item in self.itemsID[index]{
            width += itemImageHeight * CGFloat(item[1])
        }
        width += self.sameTimeItemSpace * CGFloat((self.itemsID[index].count - 1))
        return width
    }
}