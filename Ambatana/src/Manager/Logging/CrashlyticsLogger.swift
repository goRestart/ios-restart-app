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
        Crashlytics.sharedInstance().recordError()
    }
}
