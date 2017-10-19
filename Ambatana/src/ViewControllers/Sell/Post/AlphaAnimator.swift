//
//  AlphaAnimator.swift
//  LetGo
//
//  Created by Juan Iglesias on 19/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//



class AlphaAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let operation: UINavigationControllerOperation
    
    init (operation: UINavigationControllerOperation) {
        self.operation = operation
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        let containerView = transitionContext.containerView
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(fromViewController.view)
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        fromViewController.view.alpha = 1.0
        toViewController.view.alpha = 0.0
        let x = operation == .push ? finalFrame.width*2 : -finalFrame.width*2
        toViewController.view.frame = CGRect(x: x, y: 0, width: finalFrame.width, height: finalFrame.height)
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            fromViewController.view.alpha = 0.0
            toViewController.view.alpha = 1.0
            let x = self?.operation == .push ? -fromViewController.view.frame.width : fromViewController.view.frame.width
            fromViewController.view.frame = CGRect(x: x, y: 0, width: fromViewController.view.frame.width, height: fromViewController.view.frame.height)
            toViewController.view.frame = finalFrame
            }, completion: { finished in
                let cancelled = transitionContext.transitionWasCancelled
                fromViewController.view.alpha = 1.0
                transitionContext.completeTransition(!cancelled)
        })
    }
}
