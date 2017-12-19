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

    case send(params: [String : Any])

    var requiredAuthLevel: AuthLevel {
        return .nonexistent
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .send(params):
            return try Router<APIBaseURL>.create(endpoint: ContactRouter.endpoint, params: params, encoding: .json).asURLRequest()
        }
    }
}
