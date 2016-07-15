//
//  SearchesRouter.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

enum TrendingSearchesRouter: URLRequestAuthenticable {

    static let endpoint = "/api/trending_searches"

    case Index(params: [String: AnyObject])

    var requiredAuthLevel: AuthLevel {
        return .None
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case .Index(let params):
            return Router<APIBaseURL>.Index(endpoint: TrendingSearchesRouter.endpoint, params: params).URLRequest
        }
    }
}
