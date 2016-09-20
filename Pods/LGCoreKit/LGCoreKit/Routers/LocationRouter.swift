//
//  LocationRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 4/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

enum LocationRouter: URLRequestAuthenticable {

    case IPLookup

    static let endpoint = "/api/iplookup.json"

    var requiredAuthLevel: AuthLevel {
        return .None
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var URLRequest: NSMutableURLRequest {
        return Router<APIBaseURL>.Read(endpoint: LocationRouter.endpoint, params: [:]).URLRequest
    }
}
