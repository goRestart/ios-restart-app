//
//  CrashlyticsReporter.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Crashlytics
import LGCoreKit

class CrashlyticsReporter: Reporter {
    func report(_ domain: Domain, code: Int, message: String) {
        let userInfo: [AnyHashable: Any] = ["message": message]
        let error = NSError(domain: domain, code: code, userInfo: userInfo)
        Crashlytics.sharedInstance().recordError(error)
    }
}
