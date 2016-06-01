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
    case RecoverPassword(email: String)
    case Create(provider: UserSessionProvider)
    case Delete(userToken: String)

    private static let endpoint = "/authentication"

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Create, .RecoverPassword:
            return .Installation
        case .Delete:
            return .User
        }
    }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let.RecoverPassword(email):
            var params: [String: AnyObject] = [:]
            params["provider"] = "letgo-password-recovery"
            params["credentials"] = email
            let urlRequest = Router<BouncerBaseURL>.Create(endpoint: SessionRouter.endpoint, params: params,
                                                           encoding: nil).URLRequest
            if let token = InternalCore.dynamicType.tokenDAO.get(level: .Installation)?.value {
                //Force installation token as authorization
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            }
            return urlRequest
        case let .Create(provider):
            var params: [String: AnyObject] = [:]
            params["provider"] = provider.accountProvider.rawValue
            params["credentials"] = provider.credentials
            let urlRequest = Router<BouncerBaseURL>.Create(endpoint: SessionRouter.endpoint, params: params,
                encoding: nil).URLRequest
            if let token = InternalCore.dynamicType.tokenDAO.get(level: .Installation)?.value {
                //Force installation token as authorization
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            }
            return urlRequest
        case .Delete(let userToken):
            return Router<BouncerBaseURL>.Delete(endpoint: SessionRouter.endpoint, objectId: userToken).URLRequest
        }
    }
}


// MARK: - SessionProvider

private extension UserSessionProvider {
    var credentials: String {
        switch self {
        case .Email(let email, let password):
            return "\(email):\(password)"
        case .Facebook(let facebookToken):
            return facebookToken
        case .Google(let googleToken):
            return googleToken
        }
    }
}
