import UIKit

/* Custom Interactive Animation Transition Super Class UIViewController
1 present的时候，复制一个需要的view，加在container view上，然后transition结束的时候remove这个view
2 dismiss的时候，reference需要的view，加在container view上（这时自动从原来的super view上remove），如果完成transition，那么这个view被remove from superview，如果没有完成，那么这个view被加到from view 上。
dismiss的时候要注意，dismiss的view一定不能有autolayout，如果你想在IB上做，做一个container view，让这个view和其他的view autolayout，你dismiss的view仅仅用frame add到这个view，frame是全的，dismissedView protocol，不需要改frame，只需要给view，frame在这里改，可以是任何view。，然后protocol里，再给一个parent view，这样parent view add subview就可以，default parent view是viewcontroller的母view
3 这个view不care子class发生什么样的event（可以是gesture swipe的幅度，可以说slider的值，可以是whatever）后开始dismiss transition animation，他只需要知道一个数字（好update percent complete），子class根据自己的需要，要在event开始的时候，call super.dismissBegin，过程中call super.dimissChange，并且update percent，结束的时候call super.dismissComplete
*/

class InteractiveAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {
    
    // Dismiss
    let snapshot: UIView
    
    private var context:UIViewControllerContextTransitioning?

    
    private var toViewOffsetScale: offSetScale?
    private var snapOffset: offSetScale?
    private var snapStart: CGPoint?
    private var toViewStart: CGPoint?
    private var toViewStartTransform: CGAffineTransform?
    
    private var superView:UIView?
    private var ifAutoLayout:Bool = false
    
    init(snapshot:UIView) {
        self.snapshot = snapshot
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
  
        return 3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
  
    }
    
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        
    
        context = transitionContext
        context?.viewForKey(UITransitionContextFromViewKey)?.hidden = true
        
        let con = context?.containerView()
        let toView = context?.viewForKey(UITransitionContextToViewKey)
        con?.addSubview(toView!)

        toViewOffsetScale = toView!.calculateTransform(con!, toFrame: con!.bounds)

        
        toViewStart = toView?.center
        toViewStartTransform = toView?.transform

        setupSnapshot()
        con?.addSubview(snapshot)
        
        snapStart = snapshot.center
        snapOffset = toView?.transformForView2(snapshot, ofsc: toViewOffsetScale!)
    }
    
    func setupSnapshot() {
        superView = snapshot.superview
        let frame = snapshot.convertRect(snapshot.bounds, toView: nil)
        
        if snapshot.translatesAutoresizingMaskIntoConstraints == false {
            snapshot.removeFromSuperview()
            snapshot.translatesAutoresizingMaskIntoConstraints = true
            snapshot.removeConstraints(snapshot.constraints)
            ifAutoLayout = true
        }
        snapshot.frame = frame
    }
    
    func interactiveUpdate(percent:CGFloat) {
        
        let toViewPercent = toViewOffsetScale?.myPercent(percent)
        let toView = context?.viewForKey(UITransitionContextToViewKey)
        toView?.alpha = 1

        let center = CGPoint(x: (toViewStart?.x)! + (toViewPercent?.offSet.x)!, y: toViewStart!.y + (toViewPercent?.offSet.y)!)


        toView?.center = center
        toView?.transform = CGAffineTransformScale(toViewStartTransform!, (toViewPercent?.scale.x)!, (toViewPercent?.scale.y)!)
        
        let snapPercent = snapOffset?.myPercent(percent)
        let center2 = CGPoint(x: snapStart!.x + snapPercent!.offSet.x, y: snapStart!.y + snapPercent!.offSet.y)
        snapshot.center = center2
        snapshot.transform = CGAffineTransformMakeScale((snapPercent?.scale.x)!, (snapPercent?.scale.y)!)
        context?.updateInteractiveTransition(percent)
    }

    
    func interactiveComplete(percent:CGFloat, threshold:CGFloat) {
        
        let fromView = context?.viewForKey(UITransitionContextFromViewKey)
        let toView = context?.viewForKey(UITransitionContextToViewKey)
        
        if percent > threshold {
            UIView.animateWithDuration(0.6, animations: {
                toView?.alpha = 1
                toView?.transform = CGAffineTransformIdentity
          
                toView?.center = CGPoint(x: self.toViewStart!.x + (self.toViewOffsetScale?.offSet.x)!, y: self.toViewStart!.y + self.toViewOffsetScale!.offSet.y)
                
                let snapPercent = self.snapOffset
                let center2 = CGPoint(x: self.snapStart!.x + snapPercent!.offSet.x, y: self.snapStart!.y + snapPercent!.offSet.y)
                self.snapshot.center = center2
                self.snapshot.transform = CGAffineTransformMakeScale((snapPercent?.scale.x)!, (snapPercent?.scale.y)!)
       
                }, completion: {
                    _ in
                 
                    self.context?.finishInteractiveTransition()
                    self.context?.completeTransition(true)
                    self.snapshot.removeFromSuperview()
                    fromView?.hidden = false
            })
            
        } else {
            UIView.animateWithDuration(0.6, animations: {
                toView?.alpha = 0
                toView?.center = self.toViewStart!
                toView?.transform = self.toViewStartTransform!
                self.snapshot.transform = CGAffineTransformIdentity
                self.snapshot.center = self.snapStart!
                
                }, completion: {
                    _ in
                    self.context?.cancelInteractiveTransition()
                    self.context?.completeTransition(false)
                    if self.ifAutoLayout == false {
                        self.snapshot.frame = (self.superView?.bounds)!
                        self.superView!.addSubview(self.snapshot)
                    } else {
                        self.snapshot.translatesAutoresizingMaskIntoConstraints = false
                        self.superView?.addSubview(self.snapshot)
                        self.snapshot.fillInSuperView()
                    }
                    fromView?.hidden = false
            })
        }
        
        
    }
    
    func animationEnded(transitionCompleted: Bool) {
        self.context = nil
    }
    
    deinit{
        print("dis animator")
    }
}