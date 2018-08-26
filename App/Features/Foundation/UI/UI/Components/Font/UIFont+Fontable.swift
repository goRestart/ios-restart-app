import UIKit

extension UIFont: Fontable {
  public static var h1: UIFont {
    return .boldSystemFont(ofSize: 30)
  }
  
  public static var h2: UIFont {
    return .boldSystemFont(ofSize: 20)
  }
  
  public static var button: UIFont {
    return .boldSystemFont(ofSize: 16)
  }
  
  public static var tiny: UIFont {
    return .systemFont(ofSize: 12)
  }
  
  public static func body(_ thickness: Thickness) -> UIFont {
    switch thickness {
    case .regular:
      return .systemFont(ofSize: 16, weight: .regular)
    case .semibold:
      return .systemFont(ofSize: 16, weight: .semibold)
    }
  }
  
  public static func small(_ thickness: Thickness) -> UIFont {
    switch thickness {
    case .regular:
      return .systemFont(ofSize: 14, weight: .regular)
    case .semibold:
      return .systemFont(ofSize: 14, weight: .semibold)
    }
  }
}
