import UIKit

extension UIColor {
  /// Initialize UIColor with an hex value [Source](http://stackoverflow.com/a/27270584)
  ///
  /// - Parameter hex: color hex value
  convenience init(hex: Int) {
    let components = (
      R: CGFloat((hex >> 16) & 0xff) / 255.0,
      G: CGFloat((hex >> 08) & 0xff) / 255.0,
      B: CGFloat((hex >> 00) & 0xff) / 255.0
    )
    self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
  }
  
  /// Creates and returns a color object that has the same color space and component values as the receiver, but has the specified alpha component
  ///
  /// - Parameter alpha: The opacity value of the new UIColor object
  
  /// - Returns: The new UIColor object with alpha applied
  func with(alpha: CGFloat) -> UIColor {
    return withAlphaComponent(alpha)
  }
}
