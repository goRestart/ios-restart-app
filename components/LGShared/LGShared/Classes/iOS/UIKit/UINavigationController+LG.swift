extension UINavigationController {
    /**
     Helper to provide a callback to the popViewController action

     - parameter animated:   whether to animate or not
     - parameter completion: completion callback
     */
    override public func popViewController(animated: Bool, completion: (() -> Void)? = nil) {
        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            popViewController(animated: true)
            CATransaction.commit()
        } else {
            popViewController(animated: false)
            completion?()
        }
    }
}
