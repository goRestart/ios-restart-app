//
//  Logger.swift
//  LetGo
//
//  Created by Albert Hernández López on 02/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import CocoaLumberjack

public struct AppLoggingOptions: OptionSetType, CustomStringConvertible {
    public let rawValue : Int


    // MARK: - CustomStringConvertible

    public var description: String {
        var options: [String] = []
        if contains(AppLoggingOptions.Navigation) {
            options.append("⛵️")
        }
        var result = ""
        for (index, option) in options.enumerate() {
            result += option
            if index != options.count - 1 { result += "+" }
        }
        return result
    }


    // MARK: - OptionSetType

    public init(rawValue:Int) {
        self.rawValue = rawValue
    }


    // MARK: - Options

    public static var None = AppLoggingOptions(rawValue: 0)
    public static var Navigation = AppLoggingOptions(rawValue: 1)
}

enum LogLevel {
    case Verbose, Debug, Info, Warning, Error
}


func logMessage(level: LogLevel, type: AppLoggingOptions, message: String) {
    guard Debug.loggingOptions.contains(type) else { return }

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