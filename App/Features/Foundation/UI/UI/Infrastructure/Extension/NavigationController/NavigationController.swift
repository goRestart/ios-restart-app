import UIKit

public final class NavigationController: UINavigationController {
  public override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationBar()
  }
  
  private func configureNavigationBar() {
    navigationBar.setBackgroundImage(UIImage(), for: .compact)
    navigationBar.shadowImage = UIImage()
    navigationBar.barTintColor = .white
    navigationBar.isOpaque = true
    navigationBar.isTranslucent = false
  }
}
