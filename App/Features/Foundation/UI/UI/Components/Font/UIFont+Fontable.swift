import UIKit

private enum OpenSansFamily {
  static let bold = "OpenSans-Bold"
  static let semibold = "OpenSans-Semibold"
  static let regular = "OpenSans"
}

extension UIFont: Fontable {
  public static var h1: UIFont {
    return font(named: OpenSansFamily.bold, size: 28)
  }
  
  public static var h2: UIFont {
    return font(named: OpenSansFamily.bold, size: 20)
  }
  
  public static var button: UIFont {
    return font(named: OpenSansFamily.bold, size: 16)
  }
  
  public static var tiny: UIFont {
    return font(named: OpenSansFamily.regular, size: 12)
  }
  
  public static func body(_ thickness: Thickness) -> UIFont {
    switch thickness {
    case .regular:
      return font(named: OpenSansFamily.regular, size: 16)
    case .semibold:
      return font(named: OpenSansFamily.semibold, size: 16)
    }
  }
  
  public static func small(_ thickness: Thickness) -> UIFont {
    switch thickness {
    case .regular:
      return font(named: OpenSansFamily.regular, size: 14)
    case .semibold:
      return font(named: OpenSansFamily.semibold, size: 14)
    }
  }
}

private extension UIFont {
  static func font(named: String, size: CGFloat) -> UIFont {
    register(font: named)
    return UIFont(name: named, size: size)!
  }
  
  private static func register(font named: String) {
    let bundle = Bundle.framework
    let url = bundle.url(forResource: named, withExtension: "ttf")! as CFURL
    
    guard let data = CGDataProvider(url: url) else { return }
    guard let font = CGFont(data) else { return }
    CTFontManagerRegisterGraphicsFont(font, nil)
  }
}
