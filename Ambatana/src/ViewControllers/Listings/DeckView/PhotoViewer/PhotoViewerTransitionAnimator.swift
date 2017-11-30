//
//  PhotoViewerTransitioner.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

final class PhotoViewerTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let image: UIImage
    let initialFrame: CGRect

    init(image: UIImage, initialFrame: CGRect) {
        self.image = image
        self.initialFrame = initialFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)

        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!

        let toView = toVC.view!
        if let photoVC = toVC as? PhotoViewerViewController {
            photoVC.photoViewer.collectionView.reloadData()
        }

        containerView.addSubview(toView)
        toView.frame = fromView.frame
        containerView.bringSubview(toFront: fromView)

        let imageView = UIImageView(image: image)
        containerView.addSubview(imageView)
        imageView.frame = initialFrame
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill

        UIView.animate(withDuration: duration, animations: { 
            imageView.frame = fromView.frame
        }) { (completion) in
            imageView.removeFromSuperview()
            containerView.bringSubview(toFront: toView)
            transitionContext.completeTransition(true)
        }
    }
}
