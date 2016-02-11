//
//  LGCoreKitLogger.swift
//  LetGo
//
//  Created by Eli Kohen on 11/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class LGCoreKitLogger: CoreKitLogger {
    func log(level: CoreKitLoggerLevel, message: String) {
        LoggerProxy.sharedInstance.log(level.loggerLevel, message: message)
    }
}

extension CoreKitLoggerLevel {
    var loggerLevel: LoggerLevel {
        switch self {
        case .Warning:
            return .Warning
        case .Info:
            return .Info
        case .Error:
            return .Error
        }
    }
}