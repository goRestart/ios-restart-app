//
//  PassiveBuyersRouter.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

enum PassiveBuyersRouter: URLRequestAuthenticable {

    static let listingsEndpoint = "/products"

    case show(listingId: String)
    case createContacts(listingId: String, params: [String : Any])

    var endpoint: String {
        switch self {
        case let .show(listingId):
            return PassiveBuyersRouter.listingsEndpoint + "/\(listingId)/suggested_buyers"
        case let .createContacts(listingId, _):
            return PassiveBuyersRouter.listingsEndpoint + "/\(listingId)/suggested_buyers/contacts"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .show, .createContacts:
            return .user
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case .show(_):
            return try Router<PassiveBuyersBaseURL>.read(endpoint: endpoint, params: [:]).asURLRequest()
        case let .createContacts(_, params):
            return try Router<PassiveBuyersBaseURL>.create(endpoint: endpoint, params: params, encoding: .json).asURLRequest()
        }
    }
}
