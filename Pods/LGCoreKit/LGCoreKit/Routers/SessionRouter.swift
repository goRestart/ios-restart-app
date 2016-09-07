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
    case CreateUser(provider: UserSessionProvider)
    case CreateInstallation(installationId: String)
    case UpdateUser(userToken: String)
    case Delete(userToken: String)

    private static let endpoint = "/authentication"

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .CreateInstallation:
            return .None
        case .CreateUser, .RecoverPassword:
            return .Installation
        case .UpdateUser, .Delete:
            return .User
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .RecoverPassword(email):
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

        case let .CreateUser(provider):
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

        case let .CreateInstallation(installationId):
            var params: [String: AnyObject] = [:]
            params["provider"] = "installations"
            params["credentials"] = installationId
            let urlRequest = Router<BouncerBaseURL>.Create(endpoint: SessionRouter.endpoint, params: params,
                                                 encoding: nil).URLRequest
            // create installation requires not to add Authorization header
            urlRequest.setValue(nil, forHTTPHeaderField: "Authorization")
            return urlRequest
        case let .UpdateUser(userToken):
            var params: [String: AnyObject] = [:]
            params["provider"] = "renew-letgo"
            params["credentials"] = userToken
            let urlRequest = Router<BouncerBaseURL>.Create(endpoint: SessionRouter.endpoint, params: params,
                                                           encoding: nil).URLRequest
            // renew requires not to add Authorization header
            urlRequest.setValue(nil, forHTTPHeaderField: "Authorization")
            return urlRequest

        case .Delete(let userToken):
            return Router<BouncerBaseURL>.Delete(endpoint: SessionRouter.endpoint, objectId: userToken).URLRequest
        }
    }
}


// MARK: - UserSessionProvider

private extension UserSessionProvider {
    var credentials: String {
        switch self {
        case let .Email(email, password):
            return "\(email):\(password)"
        case .Facebook(let facebookToken):
            return facebookToken
        case let .Google(googleToken):
            return googleToken
        }
    }
}
