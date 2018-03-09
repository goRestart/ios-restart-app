//
//  ListingDeckViewControllerTransitionAnimator.swift
//  LetGo
//
//  Created by Facundo Menzella on 11/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

fileprivate struct Duration {
    static let transition: TimeInterval = 0.6

    static let alpha: TimeInterval = transition * 0.1
    static let layoutTargetVC: TimeInterval = transition * 0.1
    static let endTransitionTargetVC: TimeInterval = transition * 0.2

    static let transfromation: TimeInterval = transition * 0.2
}

final class ListingDeckViewControllerTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private var image: UIImage?
    private var frame: CGRect?

    private var transitioner: DeckViewTransitionMode? = DeckViewTransitionPresenter()

    init(image: UIImage?, frame: CGRect?) {
        self.image = image
        self.frame = frame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        guard let originImage = image, let originFrame = frame else {
            transitionContext.completeTransition(true)
            return
        }

        transitioner?.animateTransition(using: transitionContext,
                                       withDuration: duration,
                                       initialFrame: originFrame,
                                       image: originImage)
        transitioner = transitioner?.opposite
    }
}

private protocol DeckViewTransitionMode: class {
    var opposite: DeckViewTransitionMode? { get }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning,
                           withDuration duration: TimeInterval,
                           initialFrame: CGRect,
                           image: UIImage)
}

private class DeckViewTransitionPresenter: DeckViewTransitionMode {

    lazy var opposite: DeckViewTransitionMode? = nil
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning,
                           withDuration duration: TimeInterval,
                           initialFrame: CGRect,
                           image: UIImage) {
        guard let fromView = transitionContext.view(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) as? ListingDeckViewController,
            let toView = transitionContext.view(forKey: .to) else {
                completeTransition(using: transitionContext)
                return
        }

        let containerView = transitionContext.containerView

        containerView.addSubview(toView)
        toView.frame = fromView.frame
        
        toView.alpha = 0
        containerView.backgroundColor = toView.backgroundColor
        toView.layoutIfNeeded() // force initial layout
        
        guard let currentCell = toVC.transitionCell() else { return }
        containerView.addSubview(currentCell)
        
        let targetFrame = toVC.windowTargetFrame
        currentCell.frame = targetFrame
        currentCell.layoutIfNeeded()
        
        toVC.reloadData()
        toVC.updateStartIndex()
        
        let transform = CGAffineTransform.combineIntoTransform(targetFrame, toRect: initialFrame)
        currentCell.transform = transform

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0,
                               relativeDuration: Duration.alpha,
                               animations: { [weak fromView] in
                fromView?.alpha = 0
            })
            UIView.addKeyframe(withRelativeStartTime: 0,
                               relativeDuration: Duration.layoutTargetVC,
                               animations: { [weak toView] in
                toView?.layoutIfNeeded()
            })
            UIView.addKeyframe(withRelativeStartTime: 0,
                               relativeDuration: Duration.transfromation,
                               animations: { [weak currentCell] in
                currentCell?.transform = CGAffineTransform.identity
            })
        }) { [weak fromView, weak toView, weak currentCell, weak toVC] (_) in
            fromView?.alpha = 1
            toView?.alpha = 1
            toVC?.endTransitionAnimation()
            currentCell?.removeFromSuperview()
            self.completeTransition(using: transitionContext)
        }
    }

    private func completeTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
}

private extension CGAffineTransform {
    static func combineIntoTransform(_ from: CGRect, toRect to: CGRect) -> CGAffineTransform {
        let transform = CGAffineTransform.identity.translatedBy(x: to.midX - from.midX, y: to.midY - from.midY)
        if from.width != 0 && from.height != 0 {
            return transform.scaledBy(x: to.width/from.width, y: to.height/from.height)
        } else {
            return transform
        }
    }
}


