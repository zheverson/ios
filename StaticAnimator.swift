import UIKit

class StaticAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private var snapshot: UIView
    private var toFrame:CGRect
    private var duration:NSTimeInterval
    
    init(snapshot: UIView, toFrame:CGRect, duration:NSTimeInterval) {
        self.snapshot = snapshot
        self.toFrame = toFrame
        self.duration = duration
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        toView?.hidden = true
        
        let con = transitionContext.containerView()
        con?.addSubview(toView!)
        con?.addSubview(snapshot)
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        
        
        let offsetScale1 = snapshot.calculateTransform(con!, toFrame: toFrame)
        let offsetScale2 = snapshot.transformForView2(fromView!, ofsc: offsetScale1)
        
        let finalPositionSnap = CGPoint(x: snapshot.center.x + offsetScale1.offSet.x, y: snapshot.center.y + offsetScale1.offSet.y)
        let finalPositionFrom = CGPoint(x: (fromView?.center.x)! + offsetScale2.offSet.x, y: (fromView?.center.y)! + offsetScale2.offSet.y)
        
        UIView.animateWithDuration(duration, animations: {
            
            self.snapshot.center = finalPositionSnap
            self.snapshot.transform = CGAffineTransformScale(self.snapshot.transform, offsetScale1.scale.x, offsetScale1.scale.y)
            
            fromView?.center = finalPositionFrom
            fromView?.transform = CGAffineTransformScale((fromView?.transform)!, offsetScale2.scale.x, offsetScale2.scale.y)

            fromView?.alpha = 0
            }, completion:{
                _ in
 
                self.snapshot.removeFromSuperview()
                toView?.hidden = false
                transitionContext.completeTransition(true)
        })
    }
    
    deinit {
        print("sta animator")
    }
}


