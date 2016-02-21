
import UIKit

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 3.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let con = transitionContext.containerView()
        
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        toView?.hidden = true
        con?.addSubview(toView!)
        
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        
        // add snapshot of animated imageView
        let collectionView = (fromViewController as! UICollectionViewController).collectionView!
        let cellIndexPath = collectionView.indexPathsForSelectedItems()
        let cellVideoView = (collectionView.cellForItemAtIndexPath(cellIndexPath![0])! as! CollectionViewCell).video_thumb
        let snapshot = UIImageView(image: cellVideoView.image)
        snapshot.frame = cellVideoView.convertRect(cellVideoView.bounds, toView: nil)
        
        let animationScale = ScreenSize.width / cellVideoView.frame.width
        let upperLeft = cellVideoView.convertPoint(CGPointZero, toView: nil)
        print(upperLeft)
        
        con?.addSubview(snapshot)

        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            snapshot.transform = CGAffineTransformMakeScale(animationScale, animationScale)
            snapshot.frame.origin = CGPointZero
            fromView?.alpha = 0
            fromView?.transform = snapshot.transform
            fromView?.frame.origin = CGPoint(x: -(upperLeft.x)*animationScale,
                y: -(upperLeft.y) * animationScale)
            
            }, completion:{
                _ in
                snapshot.removeFromSuperview()
                toView?.hidden = false
                fromView?.alpha = 1
                transitionContext.completeTransition(true)
        })
    }
}