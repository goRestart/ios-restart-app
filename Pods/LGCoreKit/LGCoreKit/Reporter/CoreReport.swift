//
//  CoreReport.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/03/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

private let coreDomain = "com.letgo.ios.LGCoreKit"

// 100000..<300000
enum CoreReportNetworking: ReportType {
    case BadRequest                             // 140000
    case Unauthorized(authLevel: AuthLevel)     // 1401XX
    case NotFound                               // 140400
    case Conflict                               // 140900
    case Scammer                                // 141800
    case UnprocessableEntity                    // 142200
    case UserNotVerified                        // 142400
    case InternalServerError                    // 150000

    case InvalidJWT                             // 160000

    case Other(httpCode: Int)                   // 2XXX00

    var domain: String {
        return coreDomain
    }
    var code: Int {
        switch self {
        case .BadRequest:
            return 140000
        case let .Unauthorized(authLevel):
            let baseCode = 140100
            switch authLevel {
            case .Nonexistent:
                return baseCode
            case .Installation:
                return baseCode + 1
            case .User:
                return baseCode + 2
        }
        case .NotFound:
            return 140400
        case .Conflict:
            return 140900
        case .Scammer:
            return 141800
        case .UnprocessableEntity:
            return 142200
        case .UserNotVerified:
            return 142400
        case .InternalServerError:
            return 150000
        case .InvalidJWT:
            return 160000
        case let .Other(code):
            return 200000 + code * 100
        }
    }

    init?(apiError: ApiError, currentAuthLevel: AuthLevel? = nil) {
        switch apiError {
        case .BadRequest:
            self = .BadRequest
        case .Unauthorized where currentAuthLevel != nil:
            guard let authLevel = currentAuthLevel else { return nil }
            self = .Unauthorized(authLevel: authLevel)
        case .Scammer:
            self = .Scammer
        case .NotFound:
            self = .NotFound
        case .Conflict:
            self = .Conflict
        case .InternalServerError:
            self = .InternalServerError
        case .UnprocessableEntity:
            self = .UnprocessableEntity
        case .UserNotVerified:
            self = .UserNotVerified
        case let .Other(httpCode):
            self = .Other(httpCode: httpCode)
        case  .Network, .Internal, .NotModified, .Forbidden, .TooManyRequests, .Unauthorized:
            break
        }
        return nil
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
