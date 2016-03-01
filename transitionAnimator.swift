
import UIKit
import AVFoundation

let ScreenSize = UIScreen.mainScreen().bounds.size

class transitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {
    // Init
    var snapshot: UIView?
    let toFrame:CGRect
    let duration: NSTimeInterval
    
    // Data
    var context:UIViewControllerContextTransitioning?
    var bigViewFrame:CGRect?
    var bigViewTransform: CGAffineTransform?
    var smallViewFrame:CGRect?
    
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
                //fromView?.addSubview(self.snapshot!)
                toView?.hidden = false
                transitionContext.completeTransition(true)
                
        })
    }
    
    // MARK:Interactive Dismiss Animation
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        context = transitionContext
        context?.viewForKey(UITransitionContextFromViewKey)?.hidden = true
        let con = context?.containerView()
        let toView = context?.viewForKey(UITransitionContextToViewKey)
        bigViewFrame = toView?.frame
        smallViewFrame = snapshot?.frame
        bigViewTransform = toView?.transform
        con?.addSubview(toView!)
        con?.addSubview(snapshot!)
    }
    
    func interactiveUpdate(percent:CGFloat) {
        
        let toView = context?.viewForKey(UITransitionContextToViewKey)
        viewMapPercent(snapshot!, percent: percent, bigView: toView!)
        toView?.alpha = percent
        context?.updateInteractiveTransition(percent)
    }
    
    func interactiveComplete(percent:CGFloat, threshold:CGFloat) {
        
        let fromView = context?.viewForKey(UITransitionContextFromViewKey)
        let toView = context?.viewForKey(UITransitionContextToViewKey)
        
        if percent > threshold {
            UIView.animateWithDuration(2, animations: {
                toView?.alpha = 1
                self.viewMapPercent(self.snapshot!, percent: 1, bigView: toView!)
                
                }, completion: {
                    _ in
                    self.context?.finishInteractiveTransition()
                    self.context?.completeTransition(true)
                    self.snapshot?.removeFromSuperview()
                    fromView?.hidden = false
            })
            
        } else {
            UIView.animateWithDuration(2, animations: {
                toView?.alpha = 0
                self.viewMapPercent(self.snapshot!, percent: 0, bigView: toView!)
                
                }, completion: {
                    _ in
                    
                    self.context?.cancelInteractiveTransition()
                    self.context?.completeTransition(false)
                    fromView?.addSubview(self.snapshot!)
                    fromView?.hidden = false
            })
        }
    }
    
    // MARK:View Frame Computation
    func viewMapPercent(v:UIView, percent:CGFloat, bigView:UIView) {
        
        // UIView transform
        // Scale
        let scale = (toFrame.width) / (smallViewFrame!.width)
        let percentOfScale = (scale - 1) * percent + 1
        v.transform = CGAffineTransformMakeScale(percentOfScale, percentOfScale)
        
        // Origin
        v.frame.origin = viewOriginTransform((smallViewFrame?.origin)!, end: toFrame.origin, percent: percent)
        
        print(smallViewFrame,toFrame)
        
        // toView transform
        bigView.transform = CGAffineTransformScale(bigViewTransform!,percentOfScale,percentOfScale)
        
        bigView.frame.origin = bigViewOrigin((bigViewFrame?.origin)!, fromchild: (smallViewFrame?.origin)!, scale: percentOfScale, toChild: v.frame.origin)
    }
    
    func viewOriginTransform(begin:CGPoint, end:CGPoint, percent:CGFloat) -> CGPoint {
        let difX = end.x - begin.x
        let difY = end.y - begin.y
        let x = begin.x + difX * percent
        let y = begin.y + difY * percent
        return CGPoint(x: x, y: y)
    }
    
    func bigViewOrigin(fromParent:CGPoint, fromchild:CGPoint, scale:CGFloat, toChild:CGPoint) -> CGPoint {
        let difX = fromchild.x - fromParent.x
        let difY = fromchild.y - fromParent.y
        let x = toChild.x - difX * scale
        let y = toChild.y - difY * scale
        return CGPoint(x: x, y: y)
    }
    
    deinit{
        print(0)
    }
}





                                                                                        