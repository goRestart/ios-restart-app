//
//  CrashlyticsLogger.swift
//  LetGo
//
//  Created by Eli Kohen on 11/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Crashlytics

class CrashlyticsLogger: Logger {
    func log(level: LoggerLevel, message: String) {
        let userInfo: [NSObject : AnyObject] = ["message": message]
        let error = NSError(domain: "com.letgo.ios.LGCoreKit", code: 0, userInfo: userInfo)
        Crashlytics.sharedInstance().recordError(error)
    }
}
