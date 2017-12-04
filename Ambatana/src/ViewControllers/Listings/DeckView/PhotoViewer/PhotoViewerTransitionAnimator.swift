//
//  PhotoViewerTransitioner.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

final class PhotoViewerTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    struct Duration { static let transition: TimeInterval = 0.4 }
    private let image: UIImage
    private let initialFrame: CGRect

    private var transitioner: PhotoViewerTransitionMode = PhotoViewerTransitionPresenter()

    init(image: UIImage, initialFrame: CGRect) {
        self.image = image
        self.initialFrame = initialFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Duration.transition
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        transitioner.animateTransition(using: transitionContext, withDuration: duration,
                                       initialFrame: initialFrame, image: image)
        transitioner = transitioner.opposite
    }

    private func animationCornerRardius(from: CGFloat, to: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.fillMode = kCAFillModeBackwards

        animation.fromValue = from
        animation.toValue = to
        return animation
    }
}

private protocol PhotoViewerTransitionMode {
    var opposite: PhotoViewerTransitionMode { get }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning,
                           withDuration duration: TimeInterval,
                           initialFrame: CGRect,
                           image: UIImage)
}

private class PhotoViewerTransitionDismisser: PhotoViewerTransitionMode {
    lazy var opposite: PhotoViewerTransitionMode = PhotoViewerTransitionPresenter()

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
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            fromView.alpha = 0
            toView.alpha = 1
            imageView.frame = initialFrame
            imageView.cornerRadius = 8.0
        }, completion: { (completion) in
            imageView.removeFromSuperview()
            containerView.bringSubview(toFront: toView)
            transitionContext.completeTransition(true)
        })
    }
}

private class PhotoViewerTransitionPresenter: PhotoViewerTransitionMode {
    lazy var opposite: PhotoViewerTransitionMode = PhotoViewerTransitionDismisser()

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
        toView.frame = fromView.frame
        containerView.bringSubview(toFront: fromView)
        toView.alpha = 0

        let imageView = UIImageView(image: image)
        containerView.addSubview(imageView)
        imageView.frame = initialFrame
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius = 8.0

        UIView.animate(withDuration: 0.2, animations: {
            fromView.alpha = 0
        }) { (completion) in
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
                imageView.frame = fromView.frame
            }, completion: { (completion) in
                imageView.removeFromSuperview()
                toView.alpha = 1
                containerView.bringSubview(toFront: toView)
                transitionContext.completeTransition(true)
            })
        }
    }
}

