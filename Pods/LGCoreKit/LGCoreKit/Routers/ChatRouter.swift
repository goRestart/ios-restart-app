//
//  ChatRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 3/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

enum ChatRouter: URLRequestAuthenticable {
    
    case Index(params: [String : AnyObject])
    case Show(objectId: String, params: [String : AnyObject])
    case CreateMessage(objectId: String, params: [String : AnyObject])
    case UnreadCount
    
    var endpoint: String {
        switch self {
        case .Index:
            return "/api/products/messages"
        case .Show(let objectId, _):
            return "/api/products/\(objectId)/messages"
        case .CreateMessage(let objectId, _):
            return "/api/products/\(objectId)/messages"
        case .UnreadCount:
            return "/api/products/messages/unread-count"
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        return .User
    }
    
    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .Index(params):
            return Router<APIBaseURL>.Index(endpoint: endpoint, params: params).URLRequest
        case let .Show(_, params):
            return Router<APIBaseURL>.Read(endpoint: endpoint, params: params).URLRequest
        case let .CreateMessage(_, params):
            return Router<APIBaseURL>.Create(endpoint: endpoint, params: params, encoding: .URL).URLRequest
        case .UnreadCount:
            return Router<APIBaseURL>.Read(endpoint: endpoint, params: [:]).URLRequest
        }
    }
}
