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
    
    func nextViewOrigin() -> CGPoint {
        let x = self.frame.origin.x + self.frame.width
        let y = self.frame.origin.y + self.frame.height
        return CGPoint(x: x, y: y)
    }
    
    func addSubViews(sub:[UIView]) {
        for i in sub {
            self.addSubview(i)
        }
    }
}


