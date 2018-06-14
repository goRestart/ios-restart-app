import CocoaLumberjack

public struct AppLoggingOptions: OptionSet, CustomStringConvertible {
    public let rawValue : Int


    // MARK: - CustomStringConvertible

    public var description: String {
        var options: [String] = []
        if contains(AppLoggingOptions.navigation) {
            options.append("⛵️")
        }
        if contains(AppLoggingOptions.tracking) {
            options.append("🚜")
        }
        if contains(AppLoggingOptions.deepLink) {
            options.append("🔗")
        }
        if contains(AppLoggingOptions.monetization) {
            options.append("💰")
        }
        if contains(AppLoggingOptions.location) {
            options.append("🌏")
        }
        if contains(AppLoggingOptions.uikit) {
            options.append("👾")
        }
        if contains(AppLoggingOptions.camera) {
            options.append("📷")
        }
        if contains(AppLoggingOptions.debug) {
            options.append("🐛")
        }
        return options.joined(separator: "+")
    }


    // MARK: - OptionSetType

    public init(rawValue:Int) {
        self.rawValue = rawValue
    }


    // MARK: - Options

    public static var none = AppLoggingOptions(rawValue: 0)
    public static var navigation = AppLoggingOptions(rawValue: 1)
    public static var tracking = AppLoggingOptions(rawValue: 2)
    public static var deepLink = AppLoggingOptions(rawValue: 4)
    public static var monetization = AppLoggingOptions(rawValue: 8)
    public static var location = AppLoggingOptions(rawValue: 16)
    public static var uikit = AppLoggingOptions(rawValue: 32)
    public static var parsing = AppLoggingOptions(rawValue: 64)
    public static var camera = AppLoggingOptions(rawValue: 128)
    public static var debug = AppLoggingOptions(rawValue: 256)
}

public enum LogLevel {
    case verbose, debug, info, warning, error
}


public func logMessage(_ level: LogLevel, type: AppLoggingOptions, message: String) {
    guard Debug.loggingOptions.contains(type) else { return }

    let logText = "[\(type.description)] \(message)"
    switch level {
    case .verbose:
        DDLogVerbose(logText)
    case .debug:
        DDLogDebug(logText)
    case .info:
        DDLogInfo(logText)
    case .warning:
        DDLogWarn(logText)
    case .error:
        DDLogError(logText)
    }
}
