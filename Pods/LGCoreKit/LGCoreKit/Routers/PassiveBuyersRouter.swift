//
//  PassiveBuyersRouter.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

enum PassiveBuyersRouter: URLRequestAuthenticable {

    static let productsEndpoint = "/products"

    case Show(productId: String)
    case CreateContacts(productId: String, params: [String : AnyObject])

    var endpoint: String {
        switch self {
        case let .Show(productId):
            return PassiveBuyersRouter.productsEndpoint + "/\(productId)/suggested_buyers"
        case let .CreateContacts(productId, _):
            return PassiveBuyersRouter.productsEndpoint + "/\(productId)/suggested_buyers/contacts"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Show, .CreateContacts:
            return .User
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case .Show(_):
            return Router<PassiveBuyersBaseURL>.Read(endpoint: endpoint, params: [:]).URLRequest
        case let .CreateContacts(_, params):
            return Router<PassiveBuyersBaseURL>.Create(endpoint: endpoint, params: params, encoding: .JSON).URLRequest
        }
    }
}
