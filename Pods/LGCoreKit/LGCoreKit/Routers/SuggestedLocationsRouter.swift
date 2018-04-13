//
//  SuggestedLocationsRouter.swift
//  LGCoreKit
//
//  Created by Dídac on 09/02/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

enum SuggestedLocationsRouter: URLRequestAuthenticable {

    case retrieveSuggestedLocations(listingId: String)

    var endpoint: String {
        switch self {
        case .retrieveSuggestedLocations(let listingId):
            return "/meeting-point-suggestion/\(listingId)"
        }
    }

    var requiredAuthLevel: AuthLevel {
        return .user
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case .retrieveSuggestedLocations:
            return try Router<MeetingsBaseURL>.read(endpoint: endpoint, params: [:]).asURLRequest()
        }
    }
}
