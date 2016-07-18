//
//  ContactRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 3/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

enum ContactRouter: URLRequestAuthenticable {

    static let endpoint = "/api/contacts"

    case Send(params: [String : AnyObject])

    var requiredAuthLevel: AuthLevel {
        return .Installation
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .Send(params):
            return Router<APIBaseURL>.Create(endpoint: ContactRouter.endpoint, params: params, encoding: .JSON).URLRequest
        }
    }
}
