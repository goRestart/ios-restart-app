//
//  MyUserRouter.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 03/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Alamofire

enum MyUserRouter: URLRequestAuthenticable {

    case Show(myUserId: String)
    case Create(params: [String : AnyObject])
    case Update(myUserId: String, params: [String : AnyObject])
    case UpdateAvatar(myUserId: String, params: [String : AnyObject])
    case ResetPassword(myUserId: String, params: [String : AnyObject], token: String)
    case LinkAccount(myUserId: String, params: [String : AnyObject])
    case Counters

    private var endpoint: String {
        switch (self) {
        case .Show, .Create, .Update, .ResetPassword:
            return "/users"
        case let .UpdateAvatar(myUserId, params: _):
            return "/users/\(myUserId)/avatars"
        case let .LinkAccount(myUserId, params: _):
            return "/users/\(myUserId)/accounts"
        case .Counters:
            return "/api/users/counters"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Create:
            return .Installation
        case .Show, .Update, .UpdateAvatar, .Counters, .LinkAccount:
            return .User
        case .ResetPassword:
            return .None
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .Show(myUserId):
            return Router<BouncerBaseURL>.Show(endpoint: endpoint, objectId: myUserId).URLRequest
        case let .Create(params):
            let urlRequest = Router<BouncerBaseURL>.Create(endpoint: endpoint, params: params, encoding: nil).URLRequest
            if let token = InternalCore.dynamicType.tokenDAO.get(level: .Installation)?.value {
                //Force installation token as authorization
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            }
            return urlRequest
        case let .Update(myUserId, params):
            return Router<BouncerBaseURL>.Patch(endpoint: endpoint, objectId: myUserId, params: params,
                encoding: nil).URLRequest
        case .UpdateAvatar(_):
            return Router<BouncerBaseURL>.Create(endpoint: endpoint, params: [:], encoding: nil).URLRequest
        case let .ResetPassword(userId, params, token):
            let req = Router<BouncerBaseURL>.Patch(endpoint: endpoint, objectId: userId, params: params,
                encoding: nil).URLRequest
            req.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            return req
        case let .LinkAccount(_, params):
            return Router<BouncerBaseURL>.Create(endpoint: endpoint, params: params, encoding: nil).URLRequest
        case .Counters:
            return Router<APIBaseURL>.Index(endpoint: endpoint, params: [:]).URLRequest
        }
    }
}
