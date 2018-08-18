import Foundation

/// Returns a localized string from the application main bundle
///
/// - Parameter key: localizable key identifier
/// - Returns: localized string
public func Localize(_ key: String, _ table: String? = nil, comments: String = "") -> String {
    return NSLocalizedString(key, tableName: table, comment: comments)
}

/// Returns a string created by using a given format string as a template into which the remaining argument values are substituted according to the user's default locale
///
/// - Parameters:
///   - key: localizable key identifier
///   - arguments: list of string arguments
/// - Returns: localized string
public func Localize(_ key: String, table: String? = nil, arguments: CVarArg...) -> String {
    return String(format: Localize(key, table), arguments: arguments)
}
