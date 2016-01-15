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
    case Update(objectId: String, params: [String : AnyObject])

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Create:
            return .None
        case .Update:
            return .Installation
        }
    }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .Create(params):
            return Router<BouncerBaseURL>.Create(endpoint: InstallationRouter.endpoint, params: params, encoding: nil).URLRequest
        case let .Update(objectId, params):
            return Router<BouncerBaseURL>.Patch(endpoint: InstallationRouter.endpoint, objectId: objectId,
                params: params, encoding: nil).URLRequest
        }
    }
}
