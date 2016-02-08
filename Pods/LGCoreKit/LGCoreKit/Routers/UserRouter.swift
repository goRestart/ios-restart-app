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
    case SaveReport(userId: String, reportedUserId: String, params: [String : AnyObject])

    var endpoint: String {
        switch self {
        case .Show:
            return UserRouter.userBaseUrl
        case let .SaveReport(userId, _, _):
            return UserRouter.userBaseUrl + "/\(userId)/reports/users/"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Show:
            return .Installation
        case .SaveReport:
            return .User
        }
    }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .Show(userId):
            return Router<APIBaseURL>.Show(endpoint: endpoint, objectId: userId).URLRequest
        case let .SaveReport(_, reportedUserId, params):
            return Router<APIBaseURL>.Update(endpoint: endpoint, objectId: reportedUserId, params: params,
                encoding: nil).URLRequest
        }
    }
}
