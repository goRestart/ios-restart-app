import UIKit

private enum OpenSansFamily {
  static let bold = "OpenSans-Bold"
  static let semibold = "OpenSans-Semibold"
  static let regular = "OpenSan"
}
extension UIFont: Fontable {
  public static var h1: UIFont {
    return UIFont(name: OpenSansFamily.bold, size: 28)!
  }
  
  public static var h2: UIFont {
    return UIFont(name: OpenSansFamily.bold, size: 20)!
  }
  
  public static var button: UIFont {
    return UIFont(name: OpenSansFamily.bold, size: 16)!
  }
  
  public static var tiny: UIFont {
    return UIFont(name: OpenSansFamily.regular, size: 12)!
  }
  
  public static func body(_ thickness: Thickness) -> UIFont {
    switch thickness {
    case .regular:
      return UIFont(name: OpenSansFamily.regular, size: 16)!
    case .semibold:
      return UIFont(name: OpenSansFamily.semibold, size: 16)!
    }
  }
  
  public static func small(_ thickness: Thickness) -> UIFont {
    switch thickness {
    case .regular:
      return UIFont(name: OpenSansFamily.regular, size: 14)!
    case .semibold:
      return UIFont(name: OpenSansFamily.semibold, size: 14)!
    }
  }
}
