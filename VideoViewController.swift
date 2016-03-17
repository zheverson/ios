// View to play video, has 4 parts: 1) Video Layer; 2) ThumbImage: removed after video start play; 3) tap to play or pause; 4) time slider

import UIKit
import AVFoundation

class VideoViewController: UIViewController {
    
    
    // MARK: data property
    var player: AVPlayer? {
        didSet {
            layer?.player = player
            player?.addObserver(self, forKeyPath: "status", options: .New, context: nil)
            
            player?.currentItem?.asset.loadValuesAsynchronouslyForKeys(["duration"]) {
                [weak self] in
                self!.duration = Float(CMTimeGetSeconds((self!.player?.currentItem?.asset.duration)!))
                
            }
            
            AVObserver = player?.addPeriodicTimeObserverForInterval(CMTimeMake(1, (player!.currentTime().timescale)), queue: nil) {
                [weak self] time in
                guard self != nil else { return }
                
                let second = CGFloat(CMTimeGetSeconds(time))
                
                self!.videoSlider!.value = Float(second)
                
            }
        }
    }
    
    private var AVObserver:AnyObject?
    
    private var duration:Float? {
        didSet {
            videoSlider?.maximumValue = duration!
        }
    }
    
    // MARK: view property
    
    
    @IBOutlet weak var videoSlider: UISlider!
    
    private var layer:AVPlayerLayer?
    
    weak var thumbImageView: UIImageView?

    private let waitView = UIActivityIndicatorView()
 
    var thumbImage:UIImage?
    
    var AVView: videoLayerView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        AVView = videoLayerView()
        view.insertSubview(AVView!, belowSubview: videoSlider)
        AVView?.fillInSuperView()
        
        layer = AVView!.layer as? AVPlayerLayer
        layer?.player = player
        
        let tap = UITapGestureRecognizer(target: self, action: "videoViewTapped:")
        self.view.addGestureRecognizer(tap)
        
        videoSlider!.minimumValue = 0
        videoSlider?.maximumValue = duration ?? 1
        videoSlider?.addTarget(self, action: "sliderValueChanged:", forControlEvents:.ValueChanged )
        videoSlider?.alpha = 0
        
        if let thumbImage = thumbImage {
            //thumbImageView!.image = thumbImage
        }
   }

    

    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath! == "status" {
            
            let newValue = change?[NSKeyValueChangeNewKey] as! Int
            
            if newValue == 1 {
                if ((waitView.isAnimating()) == true) {
                    dispatch_async(dispatch_get_main_queue()){
                        self.waitView.stopAnimating()
                        self.player!.play()
                        
                    }
                }
            }
        }
    }
    
    func sliderValueChanged(slider: UISlider) {
        let cmtime = CMTimeMakeWithSeconds(Double(slider.value), (player?.currentTime().timescale)!)
        player?.seekToTime(cmtime)
    }
    
    func videoViewTapped(tap: UITapGestureRecognizer) {

        if let thumbImageView = thumbImageView{
            thumbImageView.removeFromSuperview()
            self.thumbImageView = nil
        }
        
        if player!.status == .ReadyToPlay {
            
            if player!.rate == 0 {
                
                player!.play()
                
                if let videoSlider = self.videoSlider {
                    UIView.animateWithDuration(0.5) {
                        videoSlider.alpha = 0
                    }
                }
            } else if player!.rate == 1 {
                
                player!.pause()
                
                if let videoSlider = self.videoSlider {
                    UIView.animateWithDuration(0.5) {
                        videoSlider.alpha = 1
                    }
                }
            }
        } else {
            
            waitView.frame = CGRect(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 10, height: 10)
            waitView.activityIndicatorViewStyle = .WhiteLarge
            self.view.addSubview(waitView)
            waitView.startAnimating()
        }
        
    }
    
    deinit {
        player!.removeObserver(self, forKeyPath: "status")
        player?.removeTimeObserver(AVObserver!)
        print("video view")
    }
}

class videoLayerView:UIView {
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

}
