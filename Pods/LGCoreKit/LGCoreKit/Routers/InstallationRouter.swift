//
//  InstallationRouter.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 02/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Alamofire

enum InstallationRouter: URLRequestAuthenticable {

    static let endpoint = "/installations"

    case create(params: [String : Any])
    case patch(installationId: String, params: [String : Any])

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .create:
            return .nonexistent
        case .patch:
            return .installation
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .create(params):
            return try Router<BouncerBaseURL>.create(endpoint: InstallationRouter.endpoint,
                                                     params: params, encoding: nil).asURLRequest()
        case let .patch(installationId, params):
            var urlRequest = try Router<BouncerBaseURL>.patch(endpoint: InstallationRouter.endpoint, objectId: installationId,
                                                              params: params, encoding: .json).asURLRequest()
            if let token = InternalCore.tokenDAO.get(level: .installation)?.value {
                //Force installation token as authorization
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            }
            return urlRequest
        }
    }
}
