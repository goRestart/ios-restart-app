import UIKit

extension UITabBarController {
  public func rs_setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
    viewControllers?.forEach { viewController in
      viewController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
    }
    setViewControllers(viewControllers, animated: animated)
  }
}
