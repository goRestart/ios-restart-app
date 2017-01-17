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
    case recoverPassword(email: String)
    case createUser(provider: UserSessionProvider)
    case createInstallation(installationId: String)
    case updateUser(userToken: String)
    case delete(userToken: String)
    case verify(recaptchaToken: String)

    private static let endpoint = "/authentication"

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .createInstallation:
            return .nonexistent
        case .createUser, .recoverPassword, .verify:
            return .installation
        case .updateUser, .delete:
            return .user
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .recoverPassword(email):
            var params: [String: Any] = [:]
            params["provider"] = "letgo-password-recovery"
            params["credentials"] = email
            var urlRequest = try Router<BouncerBaseURL>.create(endpoint: SessionRouter.endpoint,
                                                               params: params, encoding: nil).asURLRequest()
            if let token = type(of: InternalCore).tokenDAO.get(level: .installation)?.value {
                //Force installation token as authorization
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            }
            return urlRequest
            
        case let .createUser(provider):
            var params: [String: Any] = [:]
            params["provider"] = provider.accountProvider.rawValue
            params["credentials"] = provider.credentials
            var urlRequest = try Router<BouncerBaseURL>.create(endpoint: SessionRouter.endpoint,
                                                               params: params, encoding: nil).asURLRequest()
            if let token = type(of: InternalCore).tokenDAO.get(level: .installation)?.value {
                //Force installation token as authorization
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            }
            return urlRequest
            
        case let .createInstallation(installationId):
            var params: [String: Any] = [:]
            params["provider"] = "installations"
            params["credentials"] = installationId
            var urlRequest = try Router<BouncerBaseURL>.create(endpoint: SessionRouter.endpoint,
                                                               params: params,encoding: nil).asURLRequest()
            // create installation requires not to add Authorization header
            urlRequest.setValue(nil, forHTTPHeaderField: "Authorization")
            return urlRequest
        case let .updateUser(userToken):
            var params: [String: Any] = [:]
            params["provider"] = "renew-letgo"
            params["credentials"] = userToken
            var urlRequest = try Router<BouncerBaseURL>.create(endpoint: SessionRouter.endpoint,
                                                               params: params, encoding: nil).asURLRequest()
            // renew requires not to add Authorization header
            urlRequest.setValue(nil, forHTTPHeaderField: "Authorization")
            return urlRequest
            
        case .delete(let userToken):
            return try Router<BouncerBaseURL>.delete(endpoint: SessionRouter.endpoint, objectId: userToken).asURLRequest()
            
        case .verify(let recaptchaToken):
            var params: [String: Any] = [:]
            params["provider"] = "recaptcha"
            params["credentials"] = recaptchaToken
            var urlRequest = try Router<BouncerBaseURL>.create(endpoint: SessionRouter.endpoint, params: params,
                                                               encoding: nil).asURLRequest()
            if let token = type(of: InternalCore).tokenDAO.get(level: .installation)?.value {
                //Force installation token as authorization
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            }
            return urlRequest
        }
    }
}


// MARK: - UserSessionProvider

private extension UserSessionProvider {
    var credentials: String {
        switch self {
        case let .email(email, password):
            return "\(email):\(password)"
        case .facebook(let facebookToken):
            return facebookToken
        case let .google(googleToken):
            return googleToken
        }
    }
}
