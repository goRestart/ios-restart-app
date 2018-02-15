//
//  NiordRouter.swift
//  LGCoreKit
//
//  Created by Nestor on 17/08/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

enum NiordRouter: URLRequestAuthenticable {
    static let geocodeEndpoint = "/geocode"
    static let geocodeDetailsEndpoint = "/place/details"
    static let autocompleteEndpoint = "/autocomplete"
    
    case geocode(params: [String : Any])
    case geocodeDetails(params: [String : Any])
    case autocomplete(params: [String : Any])

    var endpoint: String {
        switch self {
        case .geocode:
            return NiordRouter.geocodeEndpoint
        case .geocodeDetails:
            return NiordRouter.geocodeDetailsEndpoint
        case .autocomplete:
            return NiordRouter.autocompleteEndpoint
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        return .installation
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .geocode(let params):
            return try Router<NiordBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case .geocodeDetails(let params):
            return try Router<NiordBaseURL>.read(endpoint: endpoint, params: params).asURLRequest()
        case .autocomplete(let params):
            return try Router<NiordBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        }
    }
}
