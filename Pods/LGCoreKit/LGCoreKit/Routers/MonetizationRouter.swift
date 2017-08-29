//
//  MonetizationRouter.swift
//  LGCoreKit
//
//  Created by Dídac on 22/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

enum MonetizationRouter: URLRequestAuthenticable {

    case showBumpeable(listingId: String, params: [String : Any])
    case freeBump(params: [String : Any])
    case pricedBump(params: [String : Any])

    static let bumpeableBaseUrl = "/api/bumpeable-products"
    static let freePaymentBaseUrl = "letgo"
    static let pricedPaymentBaseUrl = "apple"

    var endpoint: String {
        switch self {
        case let .showBumpeable(listingId, _):
            return MonetizationRouter.bumpeableBaseUrl + "/\(listingId)"
        case .freeBump:
            return MonetizationRouter.freePaymentBaseUrl
        case .pricedBump:
            return MonetizationRouter.pricedPaymentBaseUrl
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .showBumpeable, .freeBump, .pricedBump:
            return .user
        }
    }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .showBumpeable(_, params):
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .freeBump(params: params):
            return try Router<PaymentsBaseURL>.create(endpoint: endpoint, params: params, encoding: .json).asURLRequest()
        case let .pricedBump(params: params):
            return try Router<PaymentsBaseURL>.create(endpoint: endpoint, params: params, encoding: .json).asURLRequest()
        }
    }
}
