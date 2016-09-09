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

    case Create(params: [String : AnyObject])
    case Patch(installationId: String, params: [String : AnyObject])

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Create:
            return .None
        case .Patch:
            return .Installation
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .Create(params):
            return Router<BouncerBaseURL>.Create(endpoint: InstallationRouter.endpoint,
                                                 params: params, encoding: nil).URLRequest
        case let .Patch(installationId, params):
            let urlRequest = Router<BouncerBaseURL>.Patch(endpoint: InstallationRouter.endpoint, objectId: installationId,
                                                          params: params, encoding: .JSON).URLRequest
            if let token = InternalCore.dynamicType.tokenDAO.get(level: .Installation)?.value {
                //Force installation token as authorization
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            }
            return urlRequest
        }
    }
}
