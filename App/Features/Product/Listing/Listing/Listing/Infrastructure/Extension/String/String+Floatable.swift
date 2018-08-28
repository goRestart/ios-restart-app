import Foundation

extension String {
  var isFloatable: Bool {
    guard let _ = Float(self.trimmed) else { return false }
    return true
  }
  
  func toDecimal() -> Decimal {
    return Decimal(Double(self) ?? 0)
  }
}
