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
    var fromViewSnapshot: UIImage? { get }
    var completion: (() -> Void)? { get set }
    var active: Bool { get }
}

protocol AnimatableTransition {
    var animator: PushAnimator? { get }
}


class ProductCarouselPushAnimator: NSObject, PushAnimator {
    
    let originFrame: CGRect?
    let originThumbnail: UIImage?
    let animationDuration = 0.35
    let backgroundColor: UIColor
    var fromViewSnapshot: UIImage?
    var pushing = true
    var toViewValidatedFrame = false
    var completion: (() -> Void)?

    var active = false

    convenience override init() {
        self.init(originFrame: nil, originThumbnail: nil)
    }

    required init(originFrame: CGRect?, originThumbnail: UIImage?, backgroundColor: UIColor = UIColor.black) {
        self.originFrame = originFrame
        self.originThumbnail = originThumbnail
        self.backgroundColor = backgroundColor
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        active = true
        if let originFrame = originFrame {
            if pushing {
                pushFrameAnimation(transitionContext, originFrame: originFrame)
            } else {
                popFrameAnimation(transitionContext, destinationFrame: originFrame)
            }
        } else {
            fadeAnimation(transitionContext, pushing: pushing)
        }
    }
    
    private func pushFrameAnimation(_ transitionContext: UIViewControllerContextTransitioning, originFrame: CGRect) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }

        let containerView = transitionContext.containerView

        if fromViewController.containsTabBar() {
            fromViewController.tabBarController?.setTabBarHidden(true, animated: true)
        }

        let fromView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.from) ?? fromViewController.view
        let toView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.to) ?? toViewController.view
        fromViewSnapshot = fromView.takeSnapshot()
        toView.frame = fromView.frame
        toViewValidatedFrame = true
        containerView.addSubview(fromView)

        toView.alpha = 0
        
        let snapshot = UIImageView(image: originThumbnail)
        
        let backgroundColorView = UIView(frame: CGRect.zero)
        backgroundColorView.backgroundColor = backgroundColor
    
        let backgroundImage = UIImageView(image: originThumbnail)
        backgroundImage.contentMode = .scaleAspectFill
        
        let effect = UIBlurEffect(style: .light)
        let effectsView = UIVisualEffectView(effect: effect)
        let effectViewContainer = UIView(frame: CGRect.zero)
        effectViewContainer.alpha = 0
    
        effectViewContainer.addSubview(backgroundColorView)
        effectViewContainer.addSubview(backgroundImage)
        effectViewContainer.addSubview(effectsView)
        
        containerView.addSubview(effectViewContainer)
        containerView.addSubview(snapshot)
        containerView.addSubview(toView)
        snapshot.contentMode = .scaleAspectFill
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
            scale = UIScreen.main.bounds.width / originFrame.width
        } else {
            scale = UIScreen.main.bounds.height / originFrame.height
        }
        
        UIView.animate(withDuration: animationDuration, animations: {
            snapshot.transform = CGAffineTransform(scaleX: scale, y: scale)
            snapshot.center = toView.center
            effectViewContainer.alpha = 1.0
            
            },completion:{finished in
                guard finished else { return }
                UIView.animate(withDuration: 0.3, animations: {
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

    private func popFrameAnimation(_ transitionContext: UIViewControllerContextTransitioning, destinationFrame: CGRect) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        let containerView = transitionContext.containerView

        let fromView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.from) ?? fromViewController.view
        let toView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.to) ?? toViewController.view

        let originImage = UIImageView(image: fromView.takeSnapshot())
        originImage.frame = fromView.frame

        containerView.addSubview(toView)
        containerView.addSubview(originImage)
        let scaleWidth = destinationFrame.width / originImage.width
        let scaleHeight = destinationFrame.height / originImage.height

        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseIn], animations: {
            originImage.transform = CGAffineTransform(scaleX: scaleWidth, y: scaleHeight)
            originImage.center = destinationFrame.center
            originImage.alpha = 0.0
            },completion:{ [weak self] finished in
                guard finished else { return }
                if toViewController.containsTabBar() {
                    toViewController.tabBarController?.setTabBarHidden(false, animated: true)
                }
                originImage.removeFromSuperview()
                transitionContext.completeTransition(true)
                self?.completion?()
        })
    }

    private func fadeAnimation(_ transitionContext: UIViewControllerContextTransitioning, pushing: Bool) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        let containerView = transitionContext.containerView

        let fromView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.from) ?? fromViewController.view
        let toView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.to) ?? toViewController.view

        fromViewSnapshot = fromView.takeSnapshot()

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

        UIView.animate(withDuration: animationDuration, animations: {
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
