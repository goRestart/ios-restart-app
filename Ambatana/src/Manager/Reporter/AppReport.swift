//
//  AppReport.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum AppReport: Int, ReportType {
    case None
    var domain: String {
        return Constants.appDomain
    }
    var code: Int {
        return rawValue
    }
}
