import UIKit

extension UITabBarItem {
  public convenience init(image: UIImage?, tag: Int) {
    self.init(title: nil, image: image, tag: tag)
  }
}
