//
//  LoggerProxy.swift
//  LetGo
//
//  Created by Eli Kohen on 11/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class LoggerProxy: Logger {
    static let sharedInstance = LoggerProxy()
    var loggers: [Logger] = []

    convenience init() {
        self.init(loggers: [CrashlyticsLogger()])
    }

    init(loggers: [Logger]) {
        self.loggers = loggers
    }

    func log(level: LoggerLevel, message: String) {
        loggers.forEach { $0.log(level, message: message) }
    }
}
