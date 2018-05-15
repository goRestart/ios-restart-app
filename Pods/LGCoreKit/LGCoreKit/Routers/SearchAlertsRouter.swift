//
//  SearchAlertsRouter.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 05/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

enum SearchAlertsRouter: URLRequestAuthenticable {
    
    static let searchAlertBaseUrl = "/search-alert/user-search-alert"
    static let enableEndpoint = "/enable"
    static let disableEndpoint = "/disable"
    
    case create(params: [String: Any])
    case index(params: [String: Any])
    case enable(searchAlertId: String)
    case disable(searchAlertId: String)
    case delete(searchAlertId: String)
    
    var endpoint: String {
        switch self {
        case .create, .index, .delete:
            return "\(SearchAlertsRouter.searchAlertBaseUrl)"
        case let .enable(searchAlertId):
            return "\(SearchAlertsRouter.searchAlertBaseUrl)/\(searchAlertId)\(SearchAlertsRouter.enableEndpoint)"
        case let .disable(searchAlertId):
            return "\(SearchAlertsRouter.searchAlertBaseUrl)/\(searchAlertId)\(SearchAlertsRouter.disableEndpoint)"
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        return .user
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    var errorDecoderType: ErrorDecoderType? {
        return .searchAlertsError
    }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .create(params):
            return try Router<SearchAlertsBaseURL>.create(endpoint: endpoint,
                                                          params: params,
                                                          encoding: .json).asURLRequest()
        case let .index(params):
            return try Router<SearchAlertsBaseURL>.index(endpoint: endpoint,
                                                         params: params).asURLRequest()
        case .enable, .disable:
            return try Router<SearchAlertsBaseURL>.update(endpoint: endpoint,
                                                          objectId: nil,
                                                          params: [:],
                                                          encoding: nil).asURLRequest()
        case let .delete(searchAlertId):
            return try Router<SearchAlertsBaseURL>.delete(endpoint: endpoint,
                                                          objectId: searchAlertId).asURLRequest()
        }
    }
}
