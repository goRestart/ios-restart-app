//
//  Logger.swift
//  LetGo
//
//  Created by Albert Hernández López on 02/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import CocoaLumberjack

struct AppLoggingOptions: OptionSet, CustomStringConvertible {
    let rawValue : Int


    // MARK: - CustomStringConvertible

    var description: String {
        var options: [String] = []
        if contains(AppLoggingOptions.navigation) {
            options.append("⛵️")
        }
        if contains(AppLoggingOptions.tracking) {
            options.append("🚜")
        }
        if contains(AppLoggingOptions.deeplink) {
            options.append("🔗")
        }
        if contains(AppLoggingOptions.monetization) {
            options.append("💰")
        }
        return options.joined(separator: "+")
    }


    // MARK: - OptionSetType

    init(rawValue:Int) {
        self.rawValue = rawValue
    }


    // MARK: - Options

    static var none = AppLoggingOptions(rawValue: 0)
    static var navigation = AppLoggingOptions(rawValue: 1)
    static var tracking = AppLoggingOptions(rawValue: 2)
    static var deepLink = AppLoggingOptions(rawValue: 4)
    static var monetization = AppLoggingOptions(rawValue: 8)
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
