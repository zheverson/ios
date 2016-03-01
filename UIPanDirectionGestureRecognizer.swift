
import UIKit
import UIKit.UIGestureRecognizerSubclass

enum PanDirection {
    case UpToDown
    case DownToUp
    case LeftToRight
    case RightToLeft
}

class UIPanDirectionGestureRecognizer: UIPanGestureRecognizer {
    
    let direction : PanDirection
    
    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        if state == .Began {
            let velocity = velocityInView(self.view!)
            switch direction {
            case .UpToDown where velocity.y < 0 || velocity.y < fabs(velocity.x):
                state = .Cancelled
            case .DownToUp where velocity.y > 0 || velocity.y < velocity.x:
                state = .Cancelled
            case .LeftToRight where velocity.x < 0 || velocity.x < velocity.y:
                state = .Cancelled
            case .RightToLeft where velocity.x > 0 || velocity.x < velocity.y:
                state = .Cancelled
            default:
                break
            }
        }
    }
}
