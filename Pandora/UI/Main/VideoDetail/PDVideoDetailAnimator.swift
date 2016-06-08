//
//  PDVideoDetailAnimator.swift
//  Pandora
//
//  Created by xiangwenlai on 16/6/8.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDVideoDetailPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var fromRect: CGRect?
    var fromImage: UIImage?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.75
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containerView = transitionContext.containerView()
        
        guard (toVC != nil && containerView != nil && fromRect != nil) else {
            return
        }
        
        let fr = containerView!.window?.convertRect(fromRect!, toView: containerView)
        let tmpView = UIImageView(image: fromImage)
        tmpView.frame = fr!
        containerView?.addSubview(tmpView)
        containerView?.addSubview(toVC!.view)
        toVC!.view.alpha = 0
        
        let toFr = CGRect(x: fr!.minX - 300, y: fr!.minY - 300, width: fr!.width + 600, height: fr!.height + 600)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext),
                                   delay: 0,
                                   options: .CurveEaseInOut,
                                   animations: { 
                                    tmpView.frame = toFr
                                    tmpView.alpha = 0
                                    toVC!.view.alpha = 1
            }) { (finish) in
                tmpView.removeFromSuperview()
                toVC!.view.alpha = 1
                transitionContext.completeTransition(finish)
        }
    }
}

class PDVideoDetailDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containerView = transitionContext.containerView()
        
        guard toVC != nil && containerView != nil else {
            return
        }
        
        toVC!.view.alpha = 0
        containerView?.addSubview(toVC!.view)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext),
                                   delay: 0,
                                   options: .CurveEaseInOut,
                                   animations: { 
                                    toVC!.view.alpha = 1
            }) { (finish) in
                toVC!.view.alpha = 1
                transitionContext.completeTransition(finish)
        }
    }
}
