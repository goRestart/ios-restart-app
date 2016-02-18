//
//  Loggable.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 11/02/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


protocol Loggable {
}


extension Loggable {
    func logInfo(message: String) {
        log(.Info, message: message)
    }

    func logWarning(message: String) {
        log(.Warning, message: message)
    }

    func logError(message: String) {
        log(.Error, message: message)
    }

    func log(level: CoreKitLoggerLevel, message: String) {
        InternalCore.logger?.log(level, message: message)
    }
}