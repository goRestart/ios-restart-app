import UIKit

public enum Thickness {
  case semibold
  case regular
}

public protocol Fontable {
  static var h1: UIFont { get }
  static var h2: UIFont { get }
  static var button: UIFont { get }
  static var tiny: UIFont { get }
  static func body(_ thickness: Thickness) -> UIFont
  static func small(_ thickness: Thickness) -> UIFont
}
