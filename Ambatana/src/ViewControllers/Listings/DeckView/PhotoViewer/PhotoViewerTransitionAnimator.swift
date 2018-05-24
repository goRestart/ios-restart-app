//
//  PhotoViewerTransitioner.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

final class PhotoViewerTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    struct Duration {
        static let presentation: TimeInterval = 0.7
        static let dismiss: TimeInterval = 0.7
    }
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
        guard !isInteractive else { return Duration.dismiss }
        return Duration.presentation
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        transitioner.animator = self
        let (visualEffectView, imageView) = buildBlurrableImageView(withImage: image, initialFrame: initialFrame)


        transitioner.animateTransition(using: transitionContext,
                                       withDuration: duration,
                                       initialFrame: initialFrame,
                                       imageView: imageView,
                                       shouldBlurImage: true,
                                       blurredView: visualEffectView)
    }

    private func buildBlurrableImageView(withImage image: UIImage,
                                         initialFrame: CGRect) -> (UIVisualEffectView, UIImageView) {
        let imageView = buildPreviewImageView(withImage: image)
        imageView.frame = initialFrame

        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return (visualEffectView, imageView)
    }

    private func buildPreviewImageView(withImage image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius = 8.0
        return imageView
    }
}

private protocol PhotoViewerTransitionMode {
    var opposite: PhotoViewerTransitionMode { get }
    var animator: PhotoViewerTransitionAnimator? { get set }
    var isInteractive: Bool { get }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning,
                           withDuration duration: TimeInterval,
                           initialFrame: CGRect,
                           imageView: UIImageView,
                           shouldBlurImage: Bool,
                           blurredView: UIVisualEffectView)
}

private class PhotoViewerTransitionDismisser: PhotoViewerTransitionMode {
    lazy var opposite: PhotoViewerTransitionMode = PhotoViewerTransitionPresenter()
    var isInteractive: Bool { return true }

    var animator: PhotoViewerTransitionAnimator?

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning,
                           withDuration duration: TimeInterval,
                           initialFrame: CGRect,
                           imageView: UIImageView,
                           shouldBlurImage: Bool,
                           blurredView: UIVisualEffectView) {
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        toView.frame = fromView.frame

        if shouldBlurImage {
            imageView.addSubview(blurredView)
            blurredView.frame = fromView.frame
            blurredView.alpha = 1
        }

        containerView.addSubview(imageView)
        imageView.frame = fromView.bounds

        toView.alpha = 0
        let transitioner = opposite

        let blurDuration: TimeInterval = duration * 0.3
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0, options: .calculationModeLinear,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0,
                                                       relativeDuration: blurDuration,
                                                       animations: { [weak blurredView] in
                                                        blurredView?.alpha = 0
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: blurDuration,
                                                       relativeDuration: duration * 0.9,
                                                       animations: { [weak toView, weak blurredView, weak imageView] in
                                                        toView?.alpha = 1
                                                        blurredView?.alpha = 0
                                                        imageView?.frame = initialFrame
                                                        imageView?.cornerRadius = 8.0
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: duration * 0.7,
                                                       relativeDuration: duration * 0.3,
                                                       animations: { [weak imageView] in
                                                        imageView?.alpha = 0
                                    })
                                    
        }, completion: { _ in
            guard !transitionContext.transitionWasCancelled else {
                imageView.removeFromSuperview()
                toView.removeFromSuperview()
                transitionContext.completeTransition(false)
                return
            }
            fromView.alpha = 0
            self.animator?.transitioner = transitioner

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
                           imageView: UIImageView,
                           shouldBlurImage: Bool,
                           blurredView: UIVisualEffectView) {
        guard let fromView = transitionContext.view(forKey: .from),
            let photoVC = transitionContext.viewController(forKey: .to) as? PhotoViewerViewController,
            let toView = photoVC.view else {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }

        let containerView = transitionContext.containerView
        photoVC.photoViewer.reloadData()

        containerView.addSubview(toView)
        toView.frame = fromView.bounds
        containerView.bringSubview(toFront: fromView)
        toView.alpha = 0

        blurredView.alpha = 0
        
        containerView.addSubview(imageView)
        let transitioner = opposite

        if shouldBlurImage {
            imageView.addSubviewForAutoLayout(blurredView)
            blurredView.layout(with: imageView).fill()
        }

        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: .calculationModeLinear,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0,
                                   relativeDuration: duration * 0.2,
                                   animations: {
                    fromView.alpha = 0
                })
                UIView.addKeyframe(withRelativeStartTime: duration * 0,
                                   relativeDuration: duration * 0.5,
                                   animations: {
                                    imageView.frame = fromView.bounds
                                    imageView.cornerRadius = 0
                })
                UIView.addKeyframe(withRelativeStartTime: duration * 0.5,
                                   relativeDuration: duration * 0.5,
                                   animations: {
                    blurredView.alpha = 1
                })
        }, completion: { [weak self] _ in
            self?.animator?.transitioner = transitioner
            containerView.bringSubview(toFront: toView)

            fromView.alpha = 1
            toView.alpha = 1
            imageView.removeFromSuperview()
            blurredView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

