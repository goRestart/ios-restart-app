import Foundation

extension Bundle {
  static var framework: Bundle {
    return Bundle(for: Framework.self)
  }
}
private class Framework {}
