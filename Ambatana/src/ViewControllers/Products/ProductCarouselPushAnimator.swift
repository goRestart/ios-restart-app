//
//  ProductCarouselPushAnimator.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


import Foundation
import UIKit

protocol PushAnimator: UIViewControllerAnimatedTransitioning {
    var pushing: Bool { get set }
}

class ProductCarouselPushAnimator: NSObject, PushAnimator {
    
    let originFrame: CGRect?
    let originThumbnail: UIImage?
    let animationDuration = 0.35
    var pushing = true

    convenience override init() {
        self.init(originFrame: nil, originThumbnail: nil)
    }

    required init(originFrame: CGRect?, originThumbnail: UIImage?) {
        self.originFrame = originFrame
        self.originThumbnail = originThumbnail
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let originFrame = originFrame {
            pushing ? pushFrameAnimation(transitionContext, originFrame: originFrame) :
                fadeAnimation(transitionContext, pushing: false)
        } else {
            fadeAnimation(transitionContext, pushing: pushing)
        }
    }
    
    private func pushFrameAnimation(transitionContext: UIViewControllerContextTransitioning, originFrame: CGRect) {
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            else { return }
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            else { return }
        guard let containerView = transitionContext.containerView() else { return }
        
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
        
        let animationScaleHeight = UIScreen.mainScreen().bounds.height / (originFrame.height - margin*2)
        
        var scale = animationScaleHeight
        var needsRotation = false

        if let thumbnail = originThumbnail {
            let aspectRatio = thumbnail.size.height / thumbnail.size.width
            if aspectRatio < 1 {
                // horizontal image, change orientation
                needsRotation = true
                let imageAspectRatio = thumbnail.size.width/thumbnail.size.height
                let frameAspectRatio = (originFrame.size.width - margin*2)/(originFrame.size.height - margin*2)
                let widthCorrection = (originFrame.size.width - margin*2) / frameAspectRatio * imageAspectRatio
                let animationScaleWidth = UIScreen.mainScreen().bounds.height / widthCorrection
                scale = animationScaleWidth
            }
        }
        
        UIView.animateWithDuration(animationDuration, animations: {
            var transform = CGAffineTransformMakeScale(scale, scale)
            if needsRotation {
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            }
            snapshot.transform = transform
            snapshot.center = toView.center
            
            },completion:{finished in
                guard finished else { return }
                UIView.animateWithDuration(0.2, animations: {
                    toView.alpha = 1
                    }, completion: { _ in
                        fromView.removeFromSuperview()
                        snapshot.removeFromSuperview()
                        transitionContext.completeTransition(true)
                })
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
