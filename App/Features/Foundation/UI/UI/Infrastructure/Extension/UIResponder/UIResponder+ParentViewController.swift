import UIKit

extension UIResponder {
  public var parentViewController: UIViewController? {
    return (next as? UIViewController) ?? next?.parentViewController
  }
}
