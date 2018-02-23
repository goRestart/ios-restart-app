import Foundation

public func Localize(_ key: String, _ table: String? = nil, in bundle: Bundle, comments: String = "") -> String {
  return NSLocalizedString(key, tableName: table, bundle: bundle, comment: comments)
}

public func Localize(_ key: String, table: String? = nil, in bundle: Bundle, arguments: CVarArg...) -> String {
  return String(format: Localize(key, table, in: bundle, comments: ""), arguments: arguments)
}
