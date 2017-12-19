//
//  UserRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 4/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

enum UserRouter: URLRequestAuthenticable {

    static let userBaseUrl = "/api/users"
    static let bouncerUserBaseUrl = "/users"

    case show(userId: String)
    case userRelation(userId: String, params: [String : Any])
    case blockUser(userId: String, userToId: String, params: [String : Any])
    case unblockUser(userId: String, userToId: String, params: [String : Any])
    case indexBlocked(userId: String, params: [String : Any])
    case saveReport(userId: String, reportedUserId: String, params: [String : Any])

    var endpoint: String {
        switch self {
        case .show:
            return UserRouter.bouncerUserBaseUrl
        case let .userRelation(userId, _):
            return UserRouter.bouncerUserBaseUrl + "/\(userId)/links"
        case let .indexBlocked(userId, _):
            return UserRouter.bouncerUserBaseUrl + "/\(userId)/links"
        case let .blockUser(userId, _, _):
            return UserRouter.bouncerUserBaseUrl + "/\(userId)/links/"
        case let .unblockUser(userId, _, _):
            return UserRouter.bouncerUserBaseUrl + "/\(userId)/links/"
        case let .saveReport(userId, _, _):
            return UserRouter.userBaseUrl + "/\(userId)/reports/users/"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .show:
            return .installation
        case .indexBlocked, .blockUser, .unblockUser, .userRelation, .saveReport:
            return .user
        }
    }
    
    var acceptedStatus: Array<Int> {
        switch self {
        case .saveReport:
            return (200..<400).filter({$0 != 304})
        default:
            return [Int](200..<400)
        }
    }
    
    var errorDecoderType: ErrorDecoderType? {
        return .apiUsersError
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .show(userId):
            return try Router<BouncerBaseURL>.show(endpoint: endpoint, objectId: userId).asURLRequest()
        case let .userRelation(_, params):
            return try Router<BouncerBaseURL>.read(endpoint: endpoint, params: params).asURLRequest()
        case let .indexBlocked(_, params):
            return try Router<BouncerBaseURL>.read(endpoint: endpoint, params: params).asURLRequest()
        case let .blockUser(_, userToId, params):
            return try Router<BouncerBaseURL>.patch(endpoint: endpoint, objectId: userToId, params: params, encoding: .json)
                .asURLRequest()
        case let .unblockUser(_, userToId, params):
            return try Router<BouncerBaseURL>.patch(endpoint: endpoint, objectId: userToId, params: params, encoding: .json)
                .asURLRequest()
        case let .saveReport(_, reportedUserId, params):
            return try Router<APIBaseURL>.update(endpoint: endpoint, objectId: reportedUserId, params: params,
                encoding: nil).asURLRequest()
        }
    }
}
