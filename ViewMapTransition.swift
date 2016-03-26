

import UIKit

class ViewMapTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    private let animateView:UIView
    private let toFrame:CGRect
    private var duration: NSTimeInterval
    private var mydismissAnimator:InteractiveAnimator?
    var didStart:Bool = false
    
    init(animateView:UIView, toFrame:CGRect, duration:NSTimeInterval?) {
        self.animateView = animateView
        self.toFrame = toFrame
        self.duration = duration ?? 1.5
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let presentVC = presenting as! presentingVCDeleage
        let fromView = presentVC.viewToBeAnimated()
        
        let animator = StaticAnimator(snapshot: fromView, toFrame: toFrame, duration: duration)
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        mydismissAnimator = InteractiveAnimator(snapshot: animateView)
        print(2)
        return mydismissAnimator
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        print(3)
        return mydismissAnimator
    }
    
    func update(percent:CGFloat) {
        mydismissAnimator?.interactiveUpdate(percent)
    }
    
    func complete(percent:CGFloat, threshold:CGFloat) {
        mydismissAnimator?.interactiveComplete(percent, threshold: threshold)
        mydismissAnimator = nil
        didStart = false
        print(8)
    }
    
    deinit {
        print("tr dele")
    }
}