// View to play video, has 4 parts: 1) Video Layer; 2) ThumbImage: removed after video start play; 3) tap to play or pause; 4) time slider

import UIKit
import AVFoundation

class VideoView: UIView {

    var av: AVPlayer
    var videoSlider: UISlider?
    var thumbView: UIImageView?
    
    init(frame: CGRect, av: AVPlayer, duration:Float, thumb:UIImage) {
        self.av = av
        super.init(frame: frame)
    
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: "videoViewTapped")
        self.addGestureRecognizer(tapGesture)
        
        // Add Video Layer
        let layer = AVPlayerLayer(player: av)
        layer.frame = CGRect(origin: CGPointZero, size: frame.size)
        self.layer.addSublayer(layer)
        
        // Add thumbView
        thumbView = UIImageView(frame: layer.frame)
        thumbView!.image = thumb
        self.addSubview(thumbView!)
        
        // Add Slider
        addSliderToVideoView(duration)
    }
    
    func addSliderToVideoView(max: Float) {
        let width = self.frame.width
        let height = self.frame.height
        videoSlider = UISlider(frame: CGRect(x: 20, y: height - 20, width: width-40, height: 20))
        
        videoSlider!.maximumValue = max
        videoSlider!.minimumValue = 0
        videoSlider?.addTarget(self, action: "sliderTapped:", forControlEvents:.ValueChanged )
        videoSlider?.alpha = 0
        self.addSubview(videoSlider!)
    }

    func videoViewTapped() {
     
        if av.rate == 0 {
            if let thumbView = thumbView {
                thumbView.removeFromSuperview()
            }
            
            av.play()
            UIView.animateWithDuration(0.5) {
                self.videoSlider?.alpha = 0
            }
        } else if av.rate == 1 {
            av.pause()
            UIView.animateWithDuration(0.5) {
                self.videoSlider?.alpha = 1
            }
        }
    }
    
    func sliderTapped(slider: UISlider) {
        let av = (self.layer.sublayers![0] as! AVPlayerLayer).player
        let cmtime = CMTimeMakeWithSeconds(Double(slider.value), (av?.currentTime().timescale)!)
        av?.seekToTime(cmtime)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print(4)
    }
}
