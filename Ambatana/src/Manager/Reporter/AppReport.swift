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

    case monetization(error: MonetizationReportError)   // 1000..<2000
    case navigation(error: NavigationReportError)       // 2000..<3000

    var domain: String {
        return Constants.appDomain
    }

    var code: Int {
        switch self {
        case .monetization(let error):
            switch error {
            case .invalidAppstoreProductIdentifiers:
                return 1001
            }
        case .navigation(let error):
            switch error {
            case .childCoordinatorPresent:
                return 2001
            }
        }
    }
}

enum MonetizationReportError {
    case invalidAppstoreProductIdentifiers
}

enum NavigationReportError {
    case childCoordinatorPresent
}
