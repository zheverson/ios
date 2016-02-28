import UIKit

extension UIView {
    func cornerize(ratio: CGFloat?) {
        self.layer.masksToBounds = true
        if ratio != nil {
            self.layer.cornerRadius = ratio!
        } else {
            self.layer.cornerRadius = self.frame.width/2
        }
    }
}


