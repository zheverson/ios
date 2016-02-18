
import UIKit

class ItemDetailViewController: UIViewController {
    
    var contentID:Int!
    var ratio: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let videoModelURL = NSURL(string: "http://54.223.65.44:8100/content/\(self.contentID)")
        let item_times = json(videoModelURL!, type: [String:AnyObject]())
        let items = item_times["items"] as! [[[Double]]]
        let timeline = item_times["timeline"] as! [CGFloat]
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width/self.ratio+120)
        
        let videoURL = "http://54.223.65.44:8100/static/video/content/\(self.contentID)/mobile/\(self.contentID)"
        let videoview = videoView(frame: frame, url: videoURL, itemsID: items, timeline: timeline)
        
        self.view.addSubview(videoview)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
