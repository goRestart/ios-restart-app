//
//  MonetizationRouter.swift
//  LGCoreKit
//
//  Created by Dídac on 22/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

enum MonetizationRouter: URLRequestAuthenticable {

    case showBumpeable(productId: String, params: [String : Any])

    static let bumpeableBaseUrl = "/api/bumpeable-products"

    var endpoint: String {
        switch self {
        case let .showBumpeable(productId, _):
            return MonetizationRouter.bumpeableBaseUrl + "/\(productId)"
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .showBumpeable:
            return .user
        }
    }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .showBumpeable(_, params):
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        }
    }
}
