import Foundation

extension String {
  var isFloatable: Bool {
    guard let _ = Float(self.trimmed) else { return false }
    return true
  }
}
