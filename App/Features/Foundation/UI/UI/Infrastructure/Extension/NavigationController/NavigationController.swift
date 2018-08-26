import UIKit

public final class NavigationController: UINavigationController {
  public override func viewDidLoad() {
    super.viewDidLoad()
    navigationBar.setBackgroundImage(UIImage(), for: .compact)
    navigationBar.shadowImage = UIImage()
    navigationBar.barTintColor = .white
    navigationBar.isOpaque = true
  }
}
