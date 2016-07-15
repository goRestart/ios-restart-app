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
    case ShowConversation(objectId: String, params: [String : AnyObject])
    case CreateMessage(objectId: String, params: [String : AnyObject])
    case UnreadCount
    case Archive(params: [String : AnyObject])
    case Unarchive(params: [String : AnyObject])

    var endpoint: String {
        switch self {
        case .Index:
            return "/api/products/messages"
        case .Show(let objectId, _):
            return "/api/products/\(objectId)/messages"
        case .ShowConversation(let objectId, _):
            return "/api/conversations/\(objectId)/messages"
        case .CreateMessage(let objectId, _):
            return "/api/products/\(objectId)/messages"
        case .UnreadCount:
            return "/api/products/messages/unread-count"
        case .Archive:
            return "/api/products/conversations/archive"
        case .Unarchive:
            return "/api/products/conversations/archive"
        }
    }

    var requiredAuthLevel: AuthLevel {
        return .User
    }

    var reportingBlacklistedApiError: Array<ApiError> {
        switch self {
        case .Show:
            return [.NotFound, .Scammer]
        case .Index, .ShowConversation, .CreateMessage, .UnreadCount, .Archive, .Unarchive:
            return [.Scammer]
        }
    }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .Index(params):
            return Router<APIBaseURL>.Index(endpoint: endpoint, params: params).URLRequest
        case let .Show(_, params):
            return Router<APIBaseURL>.Read(endpoint: endpoint, params: params).URLRequest
        case let .ShowConversation(_, params):
            return Router<APIBaseURL>.Read(endpoint: endpoint, params: params).URLRequest
        case let .CreateMessage(_, params):
            return Router<APIBaseURL>.Create(endpoint: endpoint, params: params, encoding: .URL).URLRequest
        case .UnreadCount:
            return Router<APIBaseURL>.Read(endpoint: endpoint, params: [:]).URLRequest
        case .Archive(let params):
            return Router<APIBaseURL>.Create(endpoint: endpoint, params: params, encoding: .JSON).URLRequest
        case .Unarchive(let params):
            return Router<APIBaseURL>.BatchUpdate(endpoint: endpoint, params: params, encoding: .JSON).URLRequest
        }
    }
}
