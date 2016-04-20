//
//  ProductCarouselPushAnimator.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


import Foundation
import UIKit


class ProductCarouselPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let originFrame: CGRect
    let originThumbnail: UIImage?
    let animationDuration = 0.35

    init(originFrame: CGRect, originThumbnail: UIImage?) {
        self.originFrame = originFrame
        self.originThumbnail = originThumbnail
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as UIViewController!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as UIViewController!
        let containerView = transitionContext.containerView()!
        
        let fromView = fromViewController.view
        let toView = toViewController.view
        
        containerView.addSubview(fromView)
        
        fromViewController.tabBarController?.setTabBarHidden(true, animated: true)
        
        toView.alpha = 0
        
        let snapshot = UIImageView(image: originThumbnail)
        containerView.addSubview(snapshot)
        containerView.addSubview(toView)
        snapshot.contentMode = .ScaleAspectFill
        snapshot.clipsToBounds = true
        snapshot.layer.cornerRadius = StyleHelper.defaultCornerRadius
        
        let margin: CGFloat = 5
        snapshot.frame = CGRect(x: originFrame.origin.x + margin, y: originFrame.origin.y + margin,
                                width: originFrame.width - margin*2, height: originFrame.height - margin*2)
        
        let animationScale = UIScreen.mainScreen().bounds.height /  (originFrame.height - margin*2)
        
        UIView.animateWithDuration(animationDuration, animations: {
            snapshot.transform = CGAffineTransformMakeScale(animationScale,
                animationScale)
            snapshot.center = toView.center
            
            },completion:{finished in
                if finished {
                    UIView.animateWithDuration(0.2, animations: {
                        toView.alpha = 1
                        }, completion: { _ in
                            fromViewController.tabBarController?.setTabBarHidden(false, animated: true)
                            fromView.removeFromSuperview()
                            snapshot.removeFromSuperview()
                            transitionContext.completeTransition(true)
                    })
                    
                }
        })
    }
}
