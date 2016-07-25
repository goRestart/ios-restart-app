//
//  UserRatingRouter.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 14/07/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

enum UserRatingRouter: URLRequestAuthenticable {

    static let ratingsEndpoint = "/rating"

    case Show(objectId: String)
    case Index(params: [String : AnyObject])
    case Create(params: [String : AnyObject])
    case Update(objectId: String, params: [String : AnyObject])
    case Report(objectId: String)

    var endpoint: String {
        switch self {
        case .Show, .Index, .Create, .Update:
            return UserRatingRouter.ratingsEndpoint
        case let .Report(objectId):
            return UserRatingRouter.ratingsEndpoint+"/\(objectId)/report"

        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Index:
            return .Installation
        case .Show, .Create, .Update, .Report:
            return .User
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .Show(objectId):
            return Router<UserRatingsBaseURL>.Show(endpoint: endpoint, objectId: objectId).URLRequest
        case let .Index(params):
            return Router<UserRatingsBaseURL>.Index(endpoint: endpoint, params: params).URLRequest
        case let .Create(params):
            return Router<UserRatingsBaseURL>.Create(endpoint: endpoint, params: params, encoding: nil).URLRequest
        case let .Update(objectId, params):
            return Router<UserRatingsBaseURL>.Update(endpoint: endpoint, objectId: objectId, params: params,
                                                     encoding: nil).URLRequest
        case .Report:
            return Router<UserRatingsBaseURL>.BatchUpdate(endpoint: endpoint, params: [:], encoding: nil).URLRequest
        }
    }
}
