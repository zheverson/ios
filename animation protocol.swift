
import UIKit
protocol presentingVCDeleage:class {
    func viewToBeAnimated() -> UIView
    
    func dismissAnimatonComplete()

}

extension presentingVCDeleage {
    func dismissAnimatonComplete(){
    }
}
