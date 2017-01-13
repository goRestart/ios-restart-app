//
//  LocationRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 4/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

enum LocationRouter: URLRequestAuthenticable {

    case ipLookup

    static let endpoint = "/api/iplookup.json"

    var requiredAuthLevel: AuthLevel {
        return .nonexistent
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        return try Router<APIBaseURL>.read(endpoint: LocationRouter.endpoint, params: [:]).asURLRequest()
    }
}
