import UIKit

public extension UIImage {
  public convenience init?(name: String, in bundle: Bundle = Bundle(for: View.self)) {
    self.init(named: name, in: bundle, compatibleWith: nil)
  }
}
