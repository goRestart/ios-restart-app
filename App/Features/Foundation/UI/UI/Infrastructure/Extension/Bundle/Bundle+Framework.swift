import Foundation

extension Bundle {
  static let framework = Bundle(for: Framework.self)
}
private final class Framework {}
