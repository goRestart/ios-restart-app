//
//  MonetizationRouter.swift
//  LGCoreKit
//
//  Created by Dídac on 22/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

enum MonetizationRouter: URLRequestAuthenticable {

    case ShowBumpeable(productId: String, params: [String : AnyObject])

    static let bumpeableBaseUrl = "/api/bumpeable-products"

    var endpoint: String {
        switch self {
        case let .ShowBumpeable(productId, _):
            return MonetizationRouter.bumpeableBaseUrl + "/\(productId)"
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .ShowBumpeable:
            return .User
        }
    }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .ShowBumpeable(_, params):
            return Router<APIBaseURL>.Index(endpoint: endpoint, params: params).URLRequest
        }
    }
}
