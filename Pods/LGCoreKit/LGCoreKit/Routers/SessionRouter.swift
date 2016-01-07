//
//  SessionRouter.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 16/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation


// MARK: - SessionRouter

enum SessionRouter: URLRequestAuthenticable {
    case Create(sessionProvider: SessionProvider)
    case Delete(userToken: String)

    static let endpoint = "/authentication"

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Create:
            return .Installation
        case .Delete(_):
            return .User
        }
    }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case .Create(let sessionProvider):
            var params: [String: AnyObject] = [:]
            params["provider"] = sessionProvider.provider
            params["credentials"] = sessionProvider.credentials
            return Router<BouncerBaseURL>.Create(endpoint: SessionRouter.endpoint, params: params,
                encoding: nil).URLRequest
        case .Delete(let userToken):
            return Router<BouncerBaseURL>.Delete(endpoint: SessionRouter.endpoint, objectId: userToken).URLRequest
        }
    }
}


// MARK: - SessionProvider

private extension SessionProvider {
    var provider: String {
        switch self {
        case .ParseUser(_):
            return "parse"
        case .Email(_, _):
            return "letgo"
        case .PwdRecovery(_):
            return "letgo-password-recovery"
        case .Facebook(_):
            return "facebook"
        }
    }
    var credentials: String {
        switch self {
        case .ParseUser(let parseToken):
            return parseToken
        case .Email(let email, let password):
            return "\(email):\(password)"
        case .PwdRecovery(let email):
            return email
        case .Facebook(let facebookToken):
            return facebookToken
        }
    }
}
