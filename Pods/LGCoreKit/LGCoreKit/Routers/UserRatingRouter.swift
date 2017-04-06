//
//  UserRatingRouter.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 14/07/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

enum UserRatingRouter: URLRequestAuthenticable {

    static let ratingsEndpoint = "/rating"

    case show(objectId: String)
    case index(params: [String : Any])
    case create(params: [String : Any])
    case update(objectId: String, params: [String : Any])
    case report(objectId: String)

    var endpoint: String {
        switch self {
        case .show, .index, .create, .update:
            return UserRatingRouter.ratingsEndpoint
        case let .report(objectId):
            return UserRatingRouter.ratingsEndpoint+"/\(objectId)/report"

        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .index:
            return .nonexistent
        case .show, .create, .update, .report:
            return .user
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .show(objectId):
            return try Router<UserRatingsBaseURL>.show(endpoint: endpoint, objectId: objectId).asURLRequest()
        case let .index(params):
            return try Router<UserRatingsBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .create(params):
            return try Router<UserRatingsBaseURL>.create(endpoint: endpoint, params: params, encoding: nil).asURLRequest()
        case let .update(objectId, params):
            return try Router<UserRatingsBaseURL>.update(endpoint: endpoint, objectId: objectId, params: params, encoding: nil).asURLRequest()
        case .report:
            return try Router<UserRatingsBaseURL>.batchUpdate(endpoint: endpoint, params: [:], encoding: nil).asURLRequest()
        }
    }
}
