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

    case Show(userId: String)
    case UserRelation(userId: String, params: [String : AnyObject])
    case BlockUser(userId: String, userToId: String, params: [String : AnyObject])
    case UnblockUser(userId: String, userToId: String, params: [String : AnyObject])
    case IndexBlocked(userId: String, params: [String : AnyObject])
    case SaveReport(userId: String, reportedUserId: String, params: [String : AnyObject])

    var endpoint: String {
        switch self {
        case .Show:
            return UserRouter.userBaseUrl
        case let .UserRelation(userId, _):
            return UserRouter.bouncerUserBaseUrl + "/\(userId)/links"
        case let .IndexBlocked(userId, _):
            return UserRouter.bouncerUserBaseUrl + "/\(userId)/links"
        case let .BlockUser(userId, _, _):
            return UserRouter.bouncerUserBaseUrl + "/\(userId)/links/"
        case let .UnblockUser(userId, _, _):
            return UserRouter.bouncerUserBaseUrl + "/\(userId)/links/"
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
    
    var acceptedStatus: Array<Int> {
        switch self {
        case .SaveReport:
            return (200..<400).filter({$0 != 304})
        default:
            return [Int](200..<400)
        }
    }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .Show(userId):
            return Router<APIBaseURL>.Show(endpoint: endpoint, objectId: userId).URLRequest
        case let .UserRelation(_, params):
            return Router<BouncerBaseURL>.Read(endpoint: endpoint, params: params).URLRequest
        case let .IndexBlocked(_, params):
            return Router<BouncerBaseURL>.Read(endpoint: endpoint, params: params).URLRequest
        case let .BlockUser(_, userToId, params):
            return Router<BouncerBaseURL>.Patch(endpoint: endpoint, objectId: userToId, params: params, encoding: .JSON)
                .URLRequest
        case let .UnblockUser(_, userToId, params):
            return Router<BouncerBaseURL>.Patch(endpoint: endpoint, objectId: userToId, params: params, encoding: .JSON)
                .URLRequest
        case let .SaveReport(_, reportedUserId, params):
            return Router<APIBaseURL>.Update(endpoint: endpoint, objectId: reportedUserId, params: params,
                encoding: nil).URLRequest
        }
    }
}
