//
//  UserRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 4/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

enum UserRouter: URLRequestAuthenticable {
    
    static let endpoint = "/api/users"
    
    case Show(userId: String)
    
    var requiredAuthLevel: AuthLevel {
        return .Installation
    }
    
    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .Show(userId):
            return Router<APIBaseURL>.Show(endpoint: UserRouter.endpoint, objectId: userId).URLRequest
        }
    }
}