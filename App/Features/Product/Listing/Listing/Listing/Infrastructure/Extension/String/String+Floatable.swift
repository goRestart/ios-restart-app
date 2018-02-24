import Foundation

extension String {
  var isFloatable: Bool {
    guard let _ = Float(self) else { return false }
    return true
  }
}
