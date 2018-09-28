extension UINavigationController {
    func addFadeTransition() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade

        view.layer.add(transition, forKey: nil)
    }
}
