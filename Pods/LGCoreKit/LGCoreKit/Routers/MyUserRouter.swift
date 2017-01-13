//
//  MyUserRouter.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 03/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Alamofire

enum MyUserRouter: URLRequestAuthenticable {

    case show(myUserId: String)
    case create(params: [String : Any])
    case update(myUserId: String, params: [String : Any])
    case updateAvatar(myUserId: String, params: [String : Any])
    case resetPassword(myUserId: String, params: [String : Any], token: String)
    case linkAccount(myUserId: String, params: [String : Any])

    private var endpoint: String {
        switch (self) {
        case .show, .create, .update, .resetPassword:
            return "/users"
        case let .updateAvatar(myUserId, params: _):
            return "/users/\(myUserId)/avatars"
        case let .linkAccount(myUserId, params: _):
            return "/users/\(myUserId)/accounts"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .create:
            return .installation
        case .show, .update, .updateAvatar, .linkAccount:
            return .user
        case .resetPassword:
            return .nonexistent
        }
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .show(myUserId):
            return try Router<BouncerBaseURL>.show(endpoint: endpoint, objectId: myUserId).asURLRequest()
        case let .create(params):
            var urlRequest = try Router<BouncerBaseURL>.create(endpoint: endpoint, params: params, encoding: nil).asURLRequest()
            if let token = type(of: InternalCore).tokenDAO.get(level: .installation)?.value {
                //Force installation token as authorization
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            }
            return urlRequest
        case let .update(myUserId, params):
            return try Router<BouncerBaseURL>.patch(endpoint: endpoint, objectId: myUserId, params: params,
                                                    encoding: nil).asURLRequest()
        case .updateAvatar(_):
            return try Router<BouncerBaseURL>.create(endpoint: endpoint, params: [:], encoding: nil).asURLRequest()
        case let .resetPassword(userId, params, token):
            var req = try Router<BouncerBaseURL>.patch(endpoint: endpoint, objectId: userId, params: params,
                                                       encoding: nil).asURLRequest()
            req.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            return req
        case let .linkAccount(_, params):
            return try Router<BouncerBaseURL>.create(endpoint: endpoint, params: params, encoding: nil).asURLRequest()
        }
    }
}
