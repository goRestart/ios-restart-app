//
//  ListingDeckViewControllerTransitionAnimator.swift
//  LetGo
//
//  Created by Facundo Menzella on 11/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

fileprivate struct Duration {
    static let transition: TimeInterval = 0.4

    static let expand: TimeInterval = 0.3
    static let alpha: TimeInterval = 0.1
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
        return Duration.transition
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
    struct Height { static let gradient: CGFloat = 48.0 }

    lazy var opposite: DeckViewTransitionMode? = nil
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning,
                           withDuration duration: TimeInterval,
                           initialFrame: CGRect,
                           image: UIImage) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let fromView = transitionContext.view(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) as? ListingDeckViewController,
            let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }

        let containerView = transitionContext.containerView

        containerView.addSubview(toView)
        toView.frame = fromView.frame
        containerView.bringSubview(toFront: fromView)
        containerView.backgroundColor = toView.backgroundColor
        toView.alpha = 0

        let imageView = buildTransitionImageView(withImage: image, initialFrame: initialFrame)
        imageView.applyShadow(withOpacity: 0.6, radius: 8.0)
        containerView.addSubview(imageView)

        let targetFrame = buildTargetFrame(withTargetViewController: toVC, fromView: fromView)
        UIView.animate(withDuration: Duration.expand,
                       animations: {
                        fromView.alpha = 0
                        imageView.frame = targetFrame
        }) { (completion) in
            toVC.updateStartIndex()
            UIView.animate(withDuration: Duration.alpha,
                           animations: {
                            imageView.alpha = 0
                            toView.alpha = 1
            }, completion: { _ in
                fromView.alpha = 1
                imageView.removeFromSuperview()
                containerView.bringSubview(toFront: toView)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }

    private func buildTargetFrame(withTargetViewController toVC: ListingDeckViewController, fromView: UIView) -> CGRect {
        let top: CGFloat = toVC.navigationBarHeight + toVC.statusBarHeight

        let size = toVC.cardSystemLayoutSizeFittingSize(fromView.frame.size)
        let insets = toVC.cardInsets
        return CGRect(x: insets.left, y: top, width: size.width, height: size.height)
    }

    private func buildTransitionImageView(withImage image: UIImage, initialFrame: CGRect) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.frame = initialFrame
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Metrics.margin

        let gradient = GradientView(colors: [UIColor.black.withAlphaComponent(0.2),
                                             UIColor.black.withAlphaComponent(0)])
        let bottomGradient = GradientView(colors: [UIColor.black.withAlphaComponent(0),
                                                   UIColor.black.withAlphaComponent(0.2)])
        imageView.addSubview(gradient)
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.layout(with: imageView).fillHorizontal().top()
        gradient.layout().height(Height.gradient)

        imageView.addSubview(bottomGradient)
        bottomGradient.translatesAutoresizingMaskIntoConstraints = false
        bottomGradient.layout(with: imageView).fillHorizontal().bottom()
        bottomGradient.layout().height(Height.gradient)

        return imageView
    }
}


