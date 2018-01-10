import UIKit

open class TabBarController: UITabBarController {

  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  open override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
    viewControllers?.forEach { viewController in
      viewController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
    }
    super.setViewControllers(viewControllers, animated: animated)
  }
  
  private func setup() {
    tabBar.isTranslucent = false
    tabBar.barTintColor = .white
    tabBar.tintColor = .primary
  }
}
