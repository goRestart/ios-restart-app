//
//  PhotoViewerTransitioner.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

final class PhotoViewerTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    struct Duration { static let transition: TimeInterval = 0.3 }
    private var image: UIImage
    private let initialFrame: CGRect

    var isInteractive: Bool { return transitioner.isInteractive }
    fileprivate var transitioner: PhotoViewerTransitionMode = PhotoViewerTransitionPresenter()

    init(image: UIImage, initialFrame: CGRect) {
        self.image = image
        self.initialFrame = initialFrame
    }

    func setImage(_ image: UIImage) {
        self.image = image
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Duration.transition
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        transitioner.animator = self
        transitioner.animateTransition(using: transitionContext, withDuration: duration,
                                       initialFrame: initialFrame, image: image)
    }
}

private protocol PhotoViewerTransitionMode {
    var opposite: PhotoViewerTransitionMode { get }
    var animator: PhotoViewerTransitionAnimator? { get set }
    var isInteractive: Bool { get }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning,
                           withDuration duration: TimeInterval,
                           initialFrame: CGRect,
                           image: UIImage)
}

private class PhotoViewerTransitionDismisser: PhotoViewerTransitionMode {
    lazy var opposite: PhotoViewerTransitionMode = PhotoViewerTransitionPresenter()
    var isInteractive: Bool { return true }

    var animator: PhotoViewerTransitionAnimator?

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning,
                           withDuration duration: TimeInterval,
                           initialFrame: CGRect,
                           image: UIImage) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!

        containerView.addSubview(toView)
        toView.frame = fromView.frame

        let imageView = UIImageView(image: image)
        containerView.addSubview(imageView)
        imageView.frame = fromView.frame
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill

        toView.alpha = 0
        let transitioner = opposite
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            fromView.alpha = 0
            toView.alpha = 1
            imageView.frame = initialFrame
            imageView.cornerRadius = 8.0
        }, completion: { [weak self] (completion) in
            guard !transitionContext.transitionWasCancelled else {
                imageView.removeFromSuperview()
                toView.removeFromSuperview()
                transitionContext.completeTransition(false)
                return
            }
            self?.animator?.transitioner = transitioner

            imageView.removeFromSuperview()
            containerView.bringSubview(toFront: toView)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

private class PhotoViewerTransitionPresenter: PhotoViewerTransitionMode {
    lazy var opposite: PhotoViewerTransitionMode = PhotoViewerTransitionDismisser()
    var isInteractive: Bool { return false }

    var animator: PhotoViewerTransitionAnimator?

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning,
                           withDuration duration: TimeInterval,
                           initialFrame: CGRect,
                           image: UIImage) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!

        let toView = toVC.view!
        if let photoVC = toVC as? PhotoViewerViewController {
            photoVC.photoViewer.reloadData()
        }

        containerView.addSubview(toView)
        toView.frame = fromView.bounds
        containerView.bringSubview(toFront: fromView)
        toView.alpha = 0

        let imageView = UIImageView(image: image)
        containerView.addSubview(imageView)
        imageView.frame = initialFrame
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius = 8.0

        let transitioner = opposite
        UIView.animate(withDuration: 0.2, animations: {
            fromView.alpha = 0
        }) { (completion) in
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
                imageView.frame = fromView.bounds
            }, completion: { [weak self] (completion) in
                self?.animator?.transitioner = transitioner

                imageView.removeFromSuperview()
                toView.alpha = 1
                containerView.bringSubview(toFront: toView)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

