//
//  CoreKitLogger.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 11/02/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public enum CoreKitLoggerLevel {
    case Info, Warning, Error
}

public protocol CoreKitLogger {
    func log(level: CoreKitLoggerLevel, message: String)
}
