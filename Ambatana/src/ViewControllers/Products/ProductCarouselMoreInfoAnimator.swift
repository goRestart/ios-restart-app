//
//  ProductCarouselPushAnimator.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


import Foundation
import UIKit


class ProductCarouselMoreInfoAnimator: NSObject, PushAnimator {
    
    let originFrame: CGRect
    let animationDuration = 0.35
    var pushing = true
    
    required init(originFrame: CGRect) {
        self.originFrame = originFrame
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//        if let originFrame = originFrame where pushing {
            pushFrameAnimation(transitionContext, originFrame: originFrame)
//        } else {
//            fadeAnimation(transitionContext, pushing: pushing)
//        }
    }
    
    private func pushFrameAnimation(transitionContext: UIViewControllerContextTransitioning, originFrame: CGRect) {
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            else { return }
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            else { return }
        guard let containerView = transitionContext.containerView() else { return }
        
        let fromView = fromViewController.view
        let toView = toViewController.view
        
        toView.frame = originFrame

        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        
        UIView.animateWithDuration(animationDuration, animations: {
            toView.frame = fromView.frame
            
            },completion:{finished in
//                fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
        })
    }
    
    private func fadeAnimation(transitionContext: UIViewControllerContextTransitioning, pushing: Bool) {
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            else { return }
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            else { return }
        guard let containerView = transitionContext.containerView() else { return }
        
        let fromView = fromViewController.view
        let toView = toViewController.view
        if pushing {
            toView.alpha = 0
        }
        
        if pushing {
            fromViewController.tabBarController?.setTabBarHidden(true, animated: true)
            containerView.addSubview(fromView)
            containerView.addSubview(toView)
        } else {
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
        }
        
        UIView.animateWithDuration(animationDuration, animations: {
            if pushing {
                toView.alpha = 1
            } else {
                fromView.alpha = 0
            }
            }, completion: { finished in
                guard finished else { return }
                if !pushing {
                    toViewController.tabBarController?.setTabBarHidden(false, animated: true)
                }
                fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
        })
    }
}
