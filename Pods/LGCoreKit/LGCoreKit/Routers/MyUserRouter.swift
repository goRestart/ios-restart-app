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

    private var endpoint: String {
        switch (self) {
        case .Show, .Create, .Update, .ResetPassword:
            return "/users"
        case let .UpdateAvatar(myUserId, params: _):
            return "/avatars/\(myUserId)"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Create:
            return .Installation
        case .Show, .Update, .UpdateAvatar:
            return .User
        case .ResetPassword:
            return .None
        }
    }

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
        }
    }
}
