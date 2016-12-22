//
//  AppReport.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

// 0..<100000
enum AppReport: ReportType {

    case Monetization(error: MonetizationReportError)   // 1000..<2000

    var domain: String {
        return Constants.appDomain
    }

    var code: Int {
        switch self {
        case .Monetization(let error):
            switch error {
            case .InvalidAppstoreProductIdentifiers:
                return 1001
            }
        }
    }
}

enum MonetizationReportError {
    case InvalidAppstoreProductIdentifiers
}
