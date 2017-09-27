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
    static let suggestiveSearchWithCategoriesBaseUrl = "/searchFilter"

    case index(params: [String: Any])
    case retrieveSuggestiveSearches(params: [String: Any], shouldIncludeCategories: Bool)

    var requiredAuthLevel: AuthLevel {
        return .nonexistent
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .index(params):
            return try Router<SearchProductsBaseURL>.index(endpoint: SearchRouter.trendingSearchesBaseUrl, params: params).asURLRequest()
        case let .retrieveSuggestiveSearches(params, shouldIncludeCategories):
            let endpoint = shouldIncludeCategories ?
                SearchRouter.suggestiveSearchWithCategoriesBaseUrl : SearchRouter.suggestiveSearchBaseUrl
            return try Router<SuggestiveSearchBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        }
    }
}
