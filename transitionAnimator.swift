
import UIKit
import AVFoundation

let ScreenSize = UIScreen.mainScreen().bounds.size

class transitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {
    // Init
    private var snapshot: UIView?
    private let toFrame:CGRect
    private let duration: NSTimeInterval
    
    // Data
    private var context:UIViewControllerContextTransitioning?
    private var bigViewFrame:CGRect?
    private var bigViewTransform: CGAffineTransform?
    private var smallViewFrame:CGRect?
    
    private var superView:UIView?
    
    var ifAutoLayout:Bool = false
    init(snapshot: UIView, toFrame:CGRect, duration: NSTimeInterval){
        self.snapshot = snapshot
        self.toFrame = toFrame
        self.duration = duration
    }
    
    // MARK:Non-Interactive present animation
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        
        toView?.hidden = true
        
        let con = transitionContext.containerView()
        con?.addSubview(toView!)

        con?.addSubview(snapshot!)
        
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
  
        smallViewFrame = snapshot?.frame
        bigViewFrame = fromView?.frame
        bigViewTransform = CGAffineTransformIdentity
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            
            self.viewMapPercent(self.snapshot!, percent: 1, bigView: fromView!)
            fromView?.alpha = 0
            
            }, completion:{
                _ in
                self.snapshot?.removeFromSuperview()
                toView?.hidden = false
                transitionContext.completeTransition(true)
                
        })
    }
    
    // MARK:Interactive Dismiss Animation
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        print(4)
        context = transitionContext
        context?.viewForKey(UITransitionContextFromViewKey)?.hidden = true
        let con = context?.containerView()

        let toView = context?.viewForKey(UITransitionContextToViewKey)
     
        bigViewFrame = toView?.frame
 
        bigViewTransform = toView?.transform
        con?.addSubview(toView!)
        
        superView = snapshot?.superview
        let frame = snapshot!.convertRect(snapshot!.bounds, toView: nil)
        
        if snapshot!.translatesAutoresizingMaskIntoConstraints == false {
            snapshot?.removeFromSuperview()
            snapshot!.translatesAutoresizingMaskIntoConstraints = true
            snapshot!.removeConstraints(snapshot!.constraints)
            ifAutoLayout = true
        }

        snapshot!.frame = frame
        smallViewFrame = snapshot?.frame
        con?.addSubview(snapshot!)

    }
    
    func interactiveUpdate(percent:CGFloat) {
        print(9)
  
        let toView = context?.viewForKey(UITransitionContextToViewKey)

        viewMapPercent(snapshot!, percent: percent, bigView: toView!)
        
        toView?.alpha = percent
        context?.updateInteractiveTransition(percent)
    }
    
    func interactiveComplete(percent:CGFloat, threshold:CGFloat) {
        
        let fromView = context?.viewForKey(UITransitionContextFromViewKey)

        let toView = context?.viewForKey(UITransitionContextToViewKey)
        let toVC = context?.viewControllerForKey(UITransitionContextToViewControllerKey) as! presentingVCDeleage
        
        if percent > threshold {
            UIView.animateWithDuration(0.6, animations: {
                toView?.alpha = 1
                self.viewMapPercent(self.snapshot!, percent: 1, bigView: toView!)
                
                }, completion: {
                    _ in
                    self.context?.finishInteractiveTransition()
                    self.context?.completeTransition(true)
                    self.snapshot?.removeFromSuperview()
                    fromView?.hidden = false
                    toVC.dismissAnimatonComplete()
            })
            
        } else {
            UIView.animateWithDuration(0.6, animations: {
                toView?.alpha = 0
                self.viewMapPercent(self.snapshot!, percent: 0, bigView: toView!)
                
                }, completion: {
                    _ in
                    self.context?.cancelInteractiveTransition()
                    self.context?.completeTransition(false)
                    if self.ifAutoLayout == false {
                        self.snapshot?.frame = (self.superView?.bounds)!
                        self.superView?.addSubview(self.snapshot!)
                    } else {
                        self.snapshot?.translatesAutoresizingMaskIntoConstraints = false
                        self.superView?.addSubview(self.snapshot!)
                        self.snapshot?.fillInSuperView()
                    }
                    fromView?.hidden = false
                 
            })
        }
    }

    // MARK:View Frame Computation
    private func viewMapPercent(v:UIView, percent:CGFloat, bigView:UIView) {

        
        // UIView transform
        // Scale
        let scale = (toFrame.width) / (smallViewFrame!.width)
     
        let percentOfScale = (scale - 1) * percent + 1
        v.transform = CGAffineTransformMakeScale(percentOfScale, percentOfScale)
    
        // Origin
        v.frame.origin = viewOriginTransform((smallViewFrame?.origin)!, end: toFrame.origin, percent: percent)


        // toView transform
        bigView.transform = CGAffineTransformScale(bigViewTransform!,percentOfScale,percentOfScale)
        
        bigView.frame.origin = bigViewOrigin((bigViewFrame?.origin)!, fromchild: (smallViewFrame?.origin)!, scale: percentOfScale, toChild: v.frame.origin)

        
    }
    
    private func viewOriginTransform(begin:CGPoint, end:CGPoint, percent:CGFloat) -> CGPoint {
        let difX = end.x - begin.x
        let difY = end.y - begin.y
        let x = begin.x + difX * percent
        let y = begin.y + difY * percent
        return CGPoint(x: x, y: y)
    }
    
    private func bigViewOrigin(fromParent:CGPoint, fromchild:CGPoint, scale:CGFloat, toChild:CGPoint) -> CGPoint {
        let difX = fromchild.x - fromParent.x
        let difY = fromchild.y - fromParent.y
        let x = toChild.x - difX * scale
        let y = toChild.y - difY * scale
        return CGPoint(x: x, y: y)
    }
    
    deinit{
        print("animator")
    }
}





                                                                                        