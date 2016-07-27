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
    var toViewValidatedFrame: Bool { get }
    var completion: (() -> Void)? { get set }
}

class ProductCarouselPushAnimator: NSObject, PushAnimator {
    
    let originFrame: CGRect?
    let originThumbnail: UIImage?
    let animationDuration = 0.35
    let backgroundColor: UIColor
    var pushing = true
    var toViewValidatedFrame = false
    var completion: (() -> Void)?

    convenience override init() {
        self.init(originFrame: nil, originThumbnail: nil)
    }

    required init(originFrame: CGRect?, originThumbnail: UIImage?, backgroundColor: UIColor = UIColor.blackColor()) {
        self.originFrame = originFrame
        self.originThumbnail = originThumbnail
        self.backgroundColor = backgroundColor
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let originFrame = originFrame where pushing {
            pushFrameAnimation(transitionContext, originFrame: originFrame)
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
        
        let fromView: UIView = transitionContext.viewForKey(UITransitionContextFromViewKey) ?? fromViewController.view
        let toView: UIView = transitionContext.viewForKey(UITransitionContextToViewKey) ?? toViewController.view
        toView.frame = fromView.frame
        toViewValidatedFrame = true
        containerView.addSubview(fromView)

        if fromViewController.containsTabBar() {
            fromViewController.tabBarController?.setTabBarHidden(true, animated: true)
        }
        
        toView.alpha = 0
        
        let snapshot = UIImageView(image: originThumbnail)
        
        let backgroundColorView = UIView(frame: CGRect.zero)
        backgroundColorView.backgroundColor = backgroundColor
    
        let backgroundImage = UIImageView(image: originThumbnail)
        backgroundImage.contentMode = .ScaleAspectFill
        
        let effect = UIBlurEffect(style: .Light)
        let effectsView = UIVisualEffectView(effect: effect)
        let effectViewContainer = UIView(frame: CGRect.zero)
        effectViewContainer.alpha = 0
    
        effectViewContainer.addSubview(backgroundColorView)
        effectViewContainer.addSubview(backgroundImage)
        effectViewContainer.addSubview(effectsView)
        
        containerView.addSubview(effectViewContainer)
        containerView.addSubview(snapshot)
        containerView.addSubview(toView)
        snapshot.contentMode = .ScaleAspectFill
        snapshot.clipsToBounds = true
        snapshot.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        
        let margin: CGFloat = 5
        snapshot.frame = CGRect(x: originFrame.origin.x + margin, y: originFrame.origin.y + margin,
                                width: originFrame.width - margin*2, height: originFrame.height - margin*2)
        snapshot.frame = originFrame
        
        effectViewContainer.frame = toView.frame
        backgroundImage.frame = effectViewContainer.bounds
        effectsView.frame = effectViewContainer.bounds
        backgroundColorView.frame = effectViewContainer.bounds
        
        let scale: CGFloat
        let aspectRatio = originFrame.width / originFrame.height
        
        if aspectRatio >= LGUIKitConstants.horizontalImageMinAspectRatio {
            scale = UIScreen.mainScreen().bounds.width / originFrame.width
        } else {
            scale = UIScreen.mainScreen().bounds.height / originFrame.height
        }
        
        UIView.animateWithDuration(animationDuration, animations: {
            snapshot.transform = CGAffineTransformMakeScale(scale, scale)
            snapshot.center = toView.center
            effectViewContainer.alpha = 1.0
            
            },completion:{finished in
                guard finished else { return }
                UIView.animateWithDuration(0.3, animations: {
                    toView.alpha = 1
                    }, completion: { [weak self] _ in
                        fromView.removeFromSuperview()
                        snapshot.removeFromSuperview()
                        backgroundImage.removeFromSuperview()
                        effectsView.removeFromSuperview()
                        backgroundColorView.removeFromSuperview()
                        transitionContext.completeTransition(true)
                        self?.completion?()
                })
        })
    }

    private func fadeAnimation(transitionContext: UIViewControllerContextTransitioning, pushing: Bool) {
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            else { return }
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            else { return }
        guard let containerView = transitionContext.containerView() else { return }

        let fromView: UIView = transitionContext.viewForKey(UITransitionContextFromViewKey) ?? fromViewController.view
        let toView: UIView = transitionContext.viewForKey(UITransitionContextToViewKey) ?? toViewController.view

        if pushing {
            toView.alpha = 0
            toView.frame = fromView.frame
            toViewValidatedFrame = true

            if fromViewController.containsTabBar() {
                fromViewController.tabBarController?.setTabBarHidden(true, animated: true)
            }
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
            }, completion: { [weak self] finished in
                guard finished else { return }
                if !pushing && toViewController.containsTabBar() {
                    toViewController.tabBarController?.setTabBarHidden(false, animated: true)
                }
                fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
                self?.completion?()
        })
    }
}
