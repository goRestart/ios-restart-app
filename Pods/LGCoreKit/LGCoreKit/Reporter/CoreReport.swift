//
//  CoreReport.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/03/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

private let coreDomain = "com.letgo.ios.LGCoreKit"

// 100000..<200000
enum CoreReportNetworking: Int, ReportType {
    case UnauthorizedNone           = 140100
    case UnauthorizedInstallation   = 140101
    case UnauthorizedUser           = 140102
    case NotFound                   = 140400
    case AlreadyExists              = 140900
    case Scammer                    = 141800
    case UnprocessableEntity        = 142200
    case UserNotVerified            = 142400
    case InternalServerError        = 150000

    case InvalidJWT                 = 160000

    var domain: String {
        return coreDomain
    }
    var code: Int {
        return rawValue
    }
}

// 300000..<400000
enum CoreReportSession: Int, ReportType {
    case InsufficientTokenLevel     = 300000
    case ForcedSessionCleanup       = 300001

    var domain: String {
        return coreDomain
    }
    var code: Int {
        return rawValue
    }
}

// 400000..<500000
enum CoreReportRepository: Int, ReportType {
    case MyUserInvalidObjectId      = 400000

    var domain: String {
        return coreDomain
    }
    var code: Int {
        return rawValue
    }
}
