import Foundation

extension String {
  public var trimmed: String {
    return trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
