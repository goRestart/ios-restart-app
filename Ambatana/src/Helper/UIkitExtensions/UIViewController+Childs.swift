import Foundation

// powered by John Sundell https://medium.com/@johnsundell/using-child-view-controllers-as-plugins-in-swift-458e6b277b54

extension UIViewController {
    func add(childViewController: UIViewController) {
        addChildViewController(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParentViewController: self)
    }
    func removeFromParent() {
        guard parent != nil else { return }
        willMove(toParentViewController: nil)
        removeFromParentViewController()
        view.removeFromSuperview()
    }
}
