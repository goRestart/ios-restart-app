//
//  ProductCarouselPushAnimator.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


import Foundation
import UIKit

let animationDuration = 0.35
let screenBounds = UIScreen.mainScreen().bounds
let screenSize   = screenBounds.size
let screenWidth  = screenSize.width
let screenHeight = screenSize.height


class ProductCarouselPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let originFrame: CGRect
    let originThumbnail: UIImage?
    
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
        
        toView.alpha = 0
        
        let snapshot = UIImageView(image: originThumbnail)
        containerView.addSubview(snapshot)
        containerView.addSubview(toView)
        snapshot.contentMode = .ScaleAspectFill
        snapshot.clipsToBounds = true
        snapshot.layer.cornerRadius = StyleHelper.defaultCornerRadius
        snapshot.frame = CGRect(x: originFrame.origin.x + 5, y: originFrame.origin.y + 5, width: originFrame.width - 10, height: originFrame.height - 10)
        
        let animationScale = screenHeight /  (originFrame.height - 10)
        
        UIView.animateWithDuration(animationDuration, animations: {
            snapshot.transform = CGAffineTransformMakeScale(animationScale,
                animationScale)
            snapshot.center = toView.center
            
            },completion:{finished in
                if finished {
                    UIView.animateWithDuration(0.2, animations: {
                        toView.alpha = 1
                        }, completion: { _ in
                            fromView.removeFromSuperview()
                            snapshot.removeFromSuperview()
                            transitionContext.completeTransition(true)
                    })
                    
                }
        })
    }
}
