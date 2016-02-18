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

    case Show(userId: String)
    case UserRelation(userId: String, relatedUserId: String)
    case BlockUser(userId: String, relatedUserId: String)
    case UnblockUser(userId: String, relatedUserId: String)
    case IndexBlocked(userId: String)
    case SaveReport(userId: String, reportedUserId: String, params: [String : AnyObject])

    var endpoint: String {
        switch self {
        case .Show:
            return UserRouter.userBaseUrl
        case let .UserRelation(userId, userRelatedId):
            return UserRouter.userBaseUrl + "/\(userId)/users/\(userRelatedId)"
        case let .IndexBlocked(userId):
            return UserRouter.userBaseUrl + "/\(userId)/blocks"
        case let .BlockUser(userId, _):
            return UserRouter.userBaseUrl + "/\(userId)/blocks"
        case let .UnblockUser(userId, _):
            return UserRouter.userBaseUrl + "/\(userId)/blocks"
        case let .SaveReport(userId, _, _):
            return UserRouter.userBaseUrl + "/\(userId)/reports/users/"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Show:
            return .Installation
        case .IndexBlocked, .BlockUser, .UnblockUser, .UserRelation, .SaveReport:
            return .User
        }
    }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .Show(userId):
            return Router<APIBaseURL>.Show(endpoint: endpoint, objectId: userId).URLRequest
        case .UserRelation(_, _):
            return Router<APIBaseURL>.Read(endpoint: endpoint, params: [:]).URLRequest
        case .IndexBlocked(_):
            return Router<APIBaseURL>.Read(endpoint: endpoint, params: [:]).URLRequest
        case let .UnblockUser(_, relatedUserId):
            return Router<APIBaseURL>.Delete(endpoint: endpoint, objectId: relatedUserId).URLRequest
        case let .BlockUser(_, relatedUserId):
            return Router<APIBaseURL>.Update(endpoint: endpoint, objectId: relatedUserId, params: [:],
                encoding: nil).URLRequest
        case let .SaveReport(_, reportedUserId, params):
            return Router<APIBaseURL>.Update(endpoint: endpoint, objectId: reportedUserId, params: params,
                encoding: nil).URLRequest
        }
    }
}
