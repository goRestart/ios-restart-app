//
//  SearchRouter.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

enum SearchRouter: URLRequestAuthenticable {

    static let trendingSearchesBaseUrl = "/api/trending_searches"
    static let suggestiveSearchBaseUrl = "/search"

    case index(params: [String: Any])
    case retrieveSuggestiveSearches(params: [String: Any])

    var requiredAuthLevel: AuthLevel {
        return .nonexistent
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case .index(let params):
            return try Router<APIBaseURL>.index(endpoint: SearchRouter.trendingSearchesBaseUrl, params: params).asURLRequest()
        case .retrieveSuggestiveSearches(let params):
            return try Router<SuggestiveSearchBaseURL>.index(endpoint: SearchRouter.suggestiveSearchBaseUrl, params: params).asURLRequest()
        }
    }
}
