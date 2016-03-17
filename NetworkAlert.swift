

import UIKit

extension UIViewController {
    func networkAlertShow() {
        let alert = UIAlertController(title: "哎呀", message: "亲，网不好呀", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}



