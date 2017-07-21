//
//  TaxonomiesRouter.swift
//  LGCoreKit
//
//  Created by Dídac on 17/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

enum TaxonomiesRouter: URLRequestAuthenticable {

    static let taxonomiesEndpoint = "/api/products_taxonomies"

    case index(params: [String: Any])

    var endpoint: String {
        return TaxonomiesRouter.taxonomiesEndpoint
    }

    var requiredAuthLevel: AuthLevel {
        return .nonexistent
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case .index(let params):
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        }
    }
}
