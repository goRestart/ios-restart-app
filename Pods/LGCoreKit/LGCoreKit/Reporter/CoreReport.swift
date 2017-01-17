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
    case badRequest                                     // 140000
    case unauthorized(authLevel: AuthLevel)             // 1401XX
    case notFound                                       // 140400
    case conflict                                       // 140900
    case scammer                                        // 141800
    case unprocessableEntity                            // 142200
    case userNotVerified                                // 142400
    case internalServerError                            // 150000

    case invalidJWT(reason: CoreReportInvalidJWTReason) // 1600XX

    case other(httpCode: Int)                           // 2XXX00

    var domain: String {
        return coreDomain
    }
    var code: Int {
        switch self {
        case .badRequest:
            return 140000
        case let .unauthorized(authLevel):
            let baseCode = 140100
            switch authLevel {
            case .nonexistent:
                return baseCode
            case .installation:
                return baseCode + 1
            case .user:
                return baseCode + 2
        }
        case .notFound:
            return 140400
        case .conflict:
            return 140900
        case .scammer:
            return 141800
        case .unprocessableEntity:
            return 142200
        case .userNotVerified:
            return 142400
        case .internalServerError:
            return 150000
        case let .invalidJWT(reason):
            let baseCode = 160000
            switch reason {
            case .wrongFormat:
                return baseCode + 1
            case .unknownAuthLevel:
                return baseCode + 2
            }
        case let .other(code):
            return 200000 + code * 100
        }
    }

    init?(apiError: ApiError, currentAuthLevel: AuthLevel? = nil) {
        switch apiError {
        case .badRequest:
            self = .badRequest
        case .unauthorized where currentAuthLevel != nil:
            guard let authLevel = currentAuthLevel else { return nil }
            self = .unauthorized(authLevel: authLevel)
        case .scammer:
            self = .scammer
        case .notFound:
            self = .notFound
        case .conflict:
            self = .conflict
        case .internalServerError:
            self = .internalServerError
        case .unprocessableEntity:
            self = .unprocessableEntity
        case .userNotVerified:
            self = .userNotVerified
        case let .other(httpCode):
            self = .other(httpCode: httpCode)
        case  .network, .internalError, .notModified, .forbidden, .tooManyRequests, .unauthorized:
            break
        }
        return nil
    }
}

enum CoreReportInvalidJWTReason {
    case wrongFormat
    case unknownAuthLevel
}

// 300000..<400000
enum CoreReportSession: Int, ReportType {
    case insufficientTokenLevel     = 300000
    case forcedSessionCleanup       = 300001

    var domain: String {
        return coreDomain
    }
    var code: Int {
        return rawValue
    }
}

// 400000..<500000
enum CoreReportRepository: Int, ReportType {
    case myUserInvalidObjectId      = 400000

    var domain: String {
        return coreDomain
    }
    var code: Int {
        return rawValue
    }
}
