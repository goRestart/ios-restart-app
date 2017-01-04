//
//  CrashlyticsLogger.swift
//  LetGo
//
//  Created by Eli Kohen on 11/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import CocoaLumberjack
import Crashlytics

// https://gist.github.com/akramhussein/3c4665aabe15cfafbac2
class CrashlyticsLogger: DDAbstractLogger {
    static let sharedInstance = CrashlyticsLogger()

    private var _logFormatter : DDLogFormatter?
    override var logFormatter: DDLogFormatter? {
        get {
            return _logFormatter
        }
        set {
            _logFormatter = newValue
        }
    }

    override func logMessage(_ logMessage: DDLogMessage) {
        let message: String?
        if let logFormatter = _logFormatter {
            message = logFormatter.format(message: logMessage)
        } else {
            message = logMessage.message
        }
        if let message = message?.stringByRemovingPercentEncoding {
            CLSLogv(message, getVaList([]))
        }
    }
}
