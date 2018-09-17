final class ShareScreenshotAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 0.5
    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        let containerView = transitionContext.containerView
        
        let initialFrame: CGRect
        if isPresenting {
            initialFrame = CGRect(x: 0, y: 0, width: fromView.width, height: fromView.height)
        } else if let shareScreenshotVC = fromViewController as? ShareScreenshotViewController {
            initialFrame = CGRect(x: shareScreenshotVC.view.frame.midX - shareScreenshotVC.screenshotImageViewWidth/2,
                                  y: ShareScreenshotViewController.Layout.screenshotImageViewTopMargin + shareScreenshotVC.topBarHeight,
                                  width: shareScreenshotVC.screenshotImageViewWidth,
                                  height: shareScreenshotVC.screenshotImageViewHeight)
        } else {
            return
        }

        let finalFrame: CGRect
        if let shareScreenshotVC = toViewController as? ShareScreenshotViewController,
            isPresenting {
            finalFrame = CGRect(x: shareScreenshotVC.view.width/2 - shareScreenshotVC.screenshotImageViewWidth/2,
                                y: ShareScreenshotViewController.Layout.screenshotImageViewTopMargin + shareScreenshotVC.topBarHeight,
                                width: shareScreenshotVC.screenshotImageViewWidth,
                                height: shareScreenshotVC.screenshotImageViewHeight)
        } else {
            finalFrame = CGRect(x: 0, y: 0, width: toView.width, height: toView.height)
        }
        
        let xScaleFactor = initialFrame.width / finalFrame.width
        let yScaleFactor = initialFrame.height / finalFrame.height
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        toView.transform = scaleTransform
        toView.center = CGPoint(x: initialFrame.midX,
                                y: initialFrame.midY)
        toView.clipsToBounds = true
        
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: toView)
        
        UIView.animate(withDuration: duration,
                       delay:0.0,
                       animations: { [weak self] in
                        toView.transform = CGAffineTransform.identity
                        if self?.isPresenting == true {
                            toView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
                        } else {
                            toView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                        }
        },
                       completion: { _ in
                        transitionContext.completeTransition(true)
        }
        )
    }
    
}

extension UIViewController: UIViewControllerTransitioningDelegate {
    
    private func makeTransition(isPresenting: Bool) -> ShareScreenshotAnimator {
        return ShareScreenshotAnimator(isPresenting: isPresenting)
    }
    
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return makeTransition(isPresenting: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return makeTransition(isPresenting: false)
    }
}
