
/* Custom Interactive Animation Transition Super Class UIViewController
 1 present的时候，复制一个需要的view，加在container view上，然后transition结束的时候remove这个view
 2 dismiss的时候，reference需要的view，加在container view上（这时自动从原来的super view上remove），如果完成transition，那么这个view被remove from superview，如果没有完成，那么这个view被加到from view 上。
   dismiss的时候要注意，dismiss的view一定不能有autolayout，如果你想在IB上做，做一个container view，让这个view和其他的view autolayout，你dismiss的view仅仅用frame add到这个view，frame是全的，dismissedView protocol，不需要改frame，只需要给view，frame在这里改，可以是任何view。，然后protocol里，再给一个parent view，这样parent view add subview就可以，default parent view是viewcontroller的母view
 3 这个view不care子class发生什么样的event（可以是gesture swipe的幅度，可以说slider的值，可以是whatever）后开始dismiss transition animation，他只需要知道一个数字（好update percent complete），子class根据自己的需要，要在event开始的时候，call super.dismissBegin，过程中call super.dimissChange，并且update percent，结束的时候call super.dismissComplete
*/
import UIKit

class AnimationViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var percent:CGFloat = 0
    private var animator:transitionAnimator?
    weak var animationDelegate:presentedVCDelegate?
    
    var toFrame:CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitioningDelegate = self

    }
    
    // MARK: Non-interactive Present
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let presentingViewVC = presenting as! presentingVCDeleage
        let presentedVC = presented as! presentedVCDelegate
        
        // fromView, must already have correct frame
        let smallView = presentingViewVC.viewToBeAnimated()
        
        // toFrame
        let toFrame = presentedVC.presentFrame()
      

        let duration = presentedVC.animateDuration()
        let presentAnimator = transitionAnimator(snapshot: smallView, toFrame: toFrame, duration: duration)
        return presentAnimator
    }
    
    // MARK:Interactive Dismiss Transition
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
  
        let dismissedVC = dismissed as! presentedVCDelegate
        let dismissView = dismissedVC.viewToBeDismissed()

        animator = transitionAnimator(snapshot: dismissView, toFrame: self.toFrame!, duration: 3)
     
        return animator
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
     
        return self.animator
    }
    
    func dismissBegin(){
   
        self.dismissViewControllerAnimated(true) {
            self.percent = 0
            self.animator = nil
        }
    }
    
    func dismissChanged() {
   
        self.animator?.interactiveUpdate(percent)
    }
    
    func dismissComplete() {
        self.animator?.interactiveComplete(percent, threshold: 0.5)
    }

    // 正常来讲，找到dismiss view的frame即可，但如果用autolayout，frame depend on image ratio的时候，是不知道frame的，只能viewdidlayoutsubviews后，才知道frame，因此subclass可以override这个function，给出frame。
    
    deinit {
        print("animation controller")
    }

}




