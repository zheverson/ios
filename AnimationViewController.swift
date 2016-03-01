
// Custom Interactive Animation Transition Super UIViewController

import UIKit

class AnimationViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var percent:CGFloat = 0
    var animator:transitionAnimator?
    weak var animationDelegate:AnimationViewControllerDelegate?
    
    var toFrame:CGRect
    
    init(toFrame:CGRect){
        self.toFrame = toFrame
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitioningDelegate = self
        let pan = UIPanDirectionGestureRecognizer(direction: .UpToDown,target: self, action: "aaa:")
        self.view.addGestureRecognizer(pan)
    }
    
    
    // MARK: Non-interactive Present
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let presentingViewVC = presenting as! viewToBeAnimated
        let smallView = presentingViewVC.viewToBeAnimated()
        
        let toFrame = self.animationDelegate?.viewToBeDismissed().frame
        let duration = self.animationDelegate?.animateDuration()
        let presentAnimator = transitionAnimator(snapshot: smallView, toFrame: toFrame!, duration: duration!)
        return presentAnimator
    }
    
    // MARK:Interactive Dismiss Transition
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let dismissView = self.animationDelegate?.viewToBeDismissed()
        
        animator = transitionAnimator(snapshot: dismissView!, toFrame: self.toFrame, duration: 3)
        return animator
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return self.animator
    }
    
    func aaa(pan:UIPanGestureRecognizer) {
        switch pan.state {
        case .Began:
            self.dismissViewControllerAnimated(true) {
                self.animator = nil
            }
            
        case .Changed:
            let v = pan.view
            let translation = pan.translationInView(v)
            percent = fabs(translation.y/(v?.bounds.size.height)!)
            self.animator?.interactiveUpdate(percent)
        case .Ended:
            self.animator?.interactiveComplete(percent, threshold: 0.5)
        default: break
            
        }
    }
    
    deinit{
        print(1)
    }
}

protocol viewToBeAnimated:class {
    
    func viewToBeAnimated() -> UIView
    
}

protocol AnimationViewControllerDelegate:class {
    
    func viewToBeDismissed() -> UIView
    
    func animateDuration() -> NSTimeInterval
}