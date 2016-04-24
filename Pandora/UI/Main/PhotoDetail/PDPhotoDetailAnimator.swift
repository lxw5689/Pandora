//
//  PDPhotoDetailAnimator.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/23.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit
class PDPhotoDetailPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var imageFromFr: CGRect?
    var image: UIImage?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerVew = transitionContext.containerView()
        
        containerVew?.addSubview(toVC.view)
        toVC.view.alpha = 0
        var imgView: UIImageView!
        var destFr: CGRect!
        
        if imageFromFr != nil && image != nil {
            let rect = containerVew?.window?.convertRect(imageFromFr!, toView: containerVew!)
            let imageView = UIImageView(image: image)
            imageView.frame = rect!
            containerVew?.addSubview(imageView)
            imgView = imageView
            
            let w = containerVew!.frame.width
            let h = w / imageFromFr!.width * imageFromFr!.height
            destFr = CGRect(x: 0, y: (containerVew!.frame.height - h) / 2, width: w, height: h)
        }
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { 
            toVC.view.alpha = 1
            imgView.frame = destFr
            }) { finish in
                transitionContext.completeTransition(finish)
                if finish {
                    let detailVC = toVC as? PDPhotoDetailViewController
                    if detailVC != nil {
                        detailVC!.animImageView = imgView
                    }
                }
        }
    }
}

class PDPhotoDetailDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var fromFr: CGRect?
    var fromImage: UIImage?
    var toFr: CGRect?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerVew = transitionContext.containerView()
        
        containerVew?.addSubview(toVC.view)
        toVC.view.alpha = 0
        
        var imageView: UIImageView?
        if fromFr != nil && fromImage != nil && toFr != nil {
            imageView = UIImageView(image: fromImage)
            imageView?.frame = (containerVew?.window?.convertRect(fromFr!, toView: containerVew!))!
            containerVew?.addSubview(imageView!)
            toFr = containerVew?.window?.convertRect(toFr!, toView: containerVew!)
        }
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            toVC.view.alpha = 1
            if imageView != nil {
                imageView?.frame = self.toFr!
            }
        }) { finish in
                transitionContext.completeTransition(finish)
            if imageView != nil {
                imageView?.removeFromSuperview()
            }
        }
    }
}
