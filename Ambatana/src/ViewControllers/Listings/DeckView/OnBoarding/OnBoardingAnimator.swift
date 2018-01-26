//
//  OnBoardingAnimator.swift
//  LetGo
//
//  Created by Facundo Menzella on 25/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class OnBoardingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var presenting: Bool = true

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        if presenting {
            animatePresentation(using: transitionContext, duration: duration)
        } else {
            animatePop(using: transitionContext, duration: duration)
        }
    }

    func animatePresentation(using transitionContext: UIViewControllerContextTransitioning, duration: TimeInterval) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to),
            let toViewController = transitionContext.viewController(forKey: .to),
            let onboardingViewController = toViewController as? ListingDeckOnBoardingViewController else { return }

        containerView.addSubview(toView)
        toView.frame = containerView.frame
        onboardingViewController.prepareForPresentation()
        UIView.animate(withDuration: duration,
                       animations: {
                        onboardingViewController.finishPresentation()
        },
                       completion: { _ in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func animatePop(using transitionContext: UIViewControllerContextTransitioning, duration: TimeInterval) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
        let onboardingViewController = toViewController as? ListingDeckOnBoardingViewController else { return }

        onboardingViewController.prepareForDismissal()
        UIView.animate(withDuration: duration,
                       animations: {
                        onboardingViewController.finishDismiss()
        },
                       completion: { _ in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}


