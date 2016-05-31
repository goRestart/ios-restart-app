//
//  Logger.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/03/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import CocoaLumberjack

public struct CoreLoggingOptions: OptionSetType, CustomStringConvertible {
    public let rawValue : Int


    // MARK: - CustomStringConvertible

    public var description: String {
        var options: [String] = []
        if contains(CoreLoggingOptions.Networking) {
            options.append("✈️")
        }
        if contains(CoreLoggingOptions.Persistence) {
            options.append("💾")
        }
        if contains(CoreLoggingOptions.Token) {
            options.append("🔑")
        }
        if contains(CoreLoggingOptions.Session) {
            options.append("🙋🏻")
        }
        if contains(CoreLoggingOptions.WebSockets) {
            options.append("💬")
        }
        if contains(CoreLoggingOptions.Parsing) {
            options.append("📦")
        }
        return options.joinWithSeparator("+")
    }

    
    // MARK: - OptionSetType

    public init(rawValue:Int) {
        self.rawValue = rawValue
    }


    // MARK: - Options

    public static var None = CoreLoggingOptions(rawValue: 0)
    public static var Networking = CoreLoggingOptions(rawValue: 1)
    public static var Persistence = CoreLoggingOptions(rawValue: 2)
    public static var Token = CoreLoggingOptions(rawValue: 4)
    public static var Session = CoreLoggingOptions(rawValue: 8)
    public static var WebSockets = CoreLoggingOptions(rawValue: 16)
    public static var Parsing = CoreLoggingOptions(rawValue: 32)
}


enum LogLevel {
    case Verbose, Debug, Info, Warning, Error
}

func logMessage(level: LogLevel, type: CoreLoggingOptions, message: String) {
    guard LGCoreKit.loggingOptions.contains(type) else { return }

    let logText = "[\(type.description)] \(message)"
    switch level {
    case .Verbose:
        DDLogVerbose(logText)
    case .Debug:
        DDLogDebug(logText)
    case .Info:
        DDLogInfo(logText)
    case .Warning:
        DDLogWarn(logText)
    case .Error:
        DDLogError(logText)
    }
}
