

import UIKit
import AVKit
import AVFoundation

class ItemDetailViewController: UIViewController {
    
    var video_url: String?

    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    override func viewDidLayoutSubviews() {
        let nsurl = encodeURL(video_url!)
        let avplayer = AVPlayer(URL: nsurl)
        let av = AVPlayerViewController()
        av.player = avplayer
        av.view.frame = videoView.frame
        self.addChildViewController(av)
        self.videoView.addSubview(av.view)
        av.didMoveToParentViewController(self)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    


}
