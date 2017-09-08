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
    static let geocodeDetailsEndpoint = "/api/locations/%@/details.json"
    static let autocompleteEndpoint = "/autocomplete"
    
    case geocode(params: [String : Any])
    case geocodeDetails(placeId: String)
    case autocomplete(params: [String : Any])

    var endpoint: String {
        switch self {
        case .geocode:
            return NiordRouter.geocodeEndpoint
        case .geocodeDetails(let placeId):
            return String(format: NiordRouter.geocodeDetailsEndpoint, placeId)
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
        case .geocodeDetails:
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: [:]).asURLRequest()
        case .autocomplete(let params):
            return try Router<NiordBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        }
    }
}
