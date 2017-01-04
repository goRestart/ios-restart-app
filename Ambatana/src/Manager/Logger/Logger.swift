//
//  Logger.swift
//  LetGo
//
//  Created by Albert Hernández López on 02/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import CocoaLumberjack

public struct AppLoggingOptions: OptionSet, CustomStringConvertible {
    public let rawValue : Int


    // MARK: - CustomStringConvertible

    public var description: String {
        var options: [String] = []
        if contains(AppLoggingOptions.Navigation) {
            options.append("⛵️")
        }
        if contains(AppLoggingOptions.Tracking) {
            options.append("🚜")
        }
        if contains(AppLoggingOptions.DeepLink) {
            options.append("🔗")
        }
        if contains(AppLoggingOptions.Monetization) {
            options.append("💰")
        }
        return options.joined(separator: "+")
    }


    // MARK: - OptionSetType

    public init(rawValue:Int) {
        self.rawValue = rawValue
    }


    // MARK: - Options

    public static var None = AppLoggingOptions(rawValue: 0)
    public static var Navigation = AppLoggingOptions(rawValue: 1)
    public static var Tracking = AppLoggingOptions(rawValue: 2)
    public static var DeepLink = AppLoggingOptions(rawValue: 4)
    public static var Monetization = AppLoggingOptions(rawValue: 8)
}

enum LogLevel {
    case verbose, debug, info, warning, error
}


func logMessage(_ level: LogLevel, type: AppLoggingOptions, message: String) {
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
