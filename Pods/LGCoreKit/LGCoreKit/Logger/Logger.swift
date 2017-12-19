//
//  Logger.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/03/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import CocoaLumberjack

public struct CoreLoggingOptions: OptionSet, CustomStringConvertible {
    public let rawValue : Int


    // MARK: - CustomStringConvertible

    public var description: String {
        var options: [String] = []
        if contains(CoreLoggingOptions.networking) {
            options.append("✈️")
        }
        if contains(CoreLoggingOptions.persistence) {
            options.append("💾")
        }
        if contains(CoreLoggingOptions.token) {
            options.append("🔑")
        }
        if contains(CoreLoggingOptions.session) {
            options.append("🙋🏻")
        }
        if contains(CoreLoggingOptions.webSockets) {
            options.append("💬")
        }
        if contains(CoreLoggingOptions.parsing) {
            options.append("📦")
        }
        if contains(CoreLoggingOptions.database) {
            options.append("📝")
        }
        return options.joined(separator: "+")
    }

    
    // MARK: - OptionSetType

    public init(rawValue:Int) {
        self.rawValue = rawValue
    }


    // MARK: - Options

    public static var none = CoreLoggingOptions(rawValue: 0)
    public static var networking = CoreLoggingOptions(rawValue: 1)
    public static var persistence = CoreLoggingOptions(rawValue: 2)
    public static var token = CoreLoggingOptions(rawValue: 4)
    public static var session = CoreLoggingOptions(rawValue: 8)
    public static var webSockets = CoreLoggingOptions(rawValue: 16)
    public static var parsing = CoreLoggingOptions(rawValue: 32)
    public static var database = CoreLoggingOptions(rawValue: 64)
}


enum LogLevel {
    case verbose, debug, info, warning, error
}

func logMessage(_ level: LogLevel, type: CoreLoggingOptions, message: String) {
    guard LGCoreKit.loggingOptions.contains(type) else { return }

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
