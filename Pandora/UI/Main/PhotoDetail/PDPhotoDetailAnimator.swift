//
//  PDPhotoDetailAnimator.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/23.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit
class PDPhotoDetailPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
//        let fromFrame = transitionContext.initialFrameForViewController(fromVC!)
//        let toFrame = transitionContext.finalFrameForViewController(toVC!)
        let containerVew = transitionContext.containerView()
        containerVew?.addSubview(toVC.view)
        toVC.view.alpha = 0
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { 
            toVC.view.alpha = 1
            }) { finish in
            transitionContext.completeTransition(finish)
        }
    }
}

class PDPhotoDetailDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        //        let fromFrame = transitionContext.initialFrameForViewController(fromVC!)
        //        let toFrame = transitionContext.finalFrameForViewController(toVC!)
        let containerVew = transitionContext.containerView()
        containerVew?.addSubview(toVC.view)
        toVC.view.alpha = 0
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            toVC.view.alpha = 1
        }) { finish in
                transitionContext.completeTransition(finish)
        }
    }
}
