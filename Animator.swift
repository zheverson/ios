
import UIKit

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let vc1 = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let vc2 = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let v2 = transitionContext.viewForKey(UITransitionContextToViewKey)
        let con = transitionContext.containerView()
        let collectionView = (vc1 as! UICollectionViewController).collectionView!
        let cellIndexPath = collectionView.indexPathsForSelectedItems()
        
        
        let frame = collectionView.cellForItemAtIndexPath(cellIndexPath![0])!.frame

        let frameToScreen = collectionView.convertRect(frame, toView: collectionView.superview)

        v2!.frame = frameToScreen
        let endFrame2 = transitionContext.finalFrameForViewController(vc2!)
        con?.addSubview(v2!)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            v2?.frame = endFrame2
            }, completion:{
                _ in
                transitionContext.completeTransition(true)
        })
    }
}