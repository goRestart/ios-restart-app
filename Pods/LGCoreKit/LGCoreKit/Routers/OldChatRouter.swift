//
//  ChatRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 3/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

enum OldChatRouter: URLRequestAuthenticable {

    case index(params: [String : Any])
    case show(objectId: String, params: [String : Any])
    case showConversation(objectId: String, params: [String : Any])
    case createMessage(objectId: String, params: [String : Any])
    case unreadCount
    case archive(params: [String : Any])
    case unarchive(params: [String : Any])

    var endpoint: String {
        switch self {
        case .index:
            return "/api/products/messages"
        case .show(let objectId, _):
            return "/api/products/\(objectId)/messages"
        case .showConversation(let objectId, _):
            return "/api/conversations/\(objectId)/messages"
        case .createMessage(let objectId, _):
            return "/api/products/\(objectId)/messages"
        case .unreadCount:
            return "/api/products/messages/unread-count"
        case .archive:
            return "/api/products/conversations/archive"
        case .unarchive:
            return "/api/products/conversations/archive"
        }
    }

    var requiredAuthLevel: AuthLevel {
        return .user
    }

    var reportingBlacklistedApiError: Array<ApiError> {
        switch self {
        case .show:
            return [.notFound, .scammer]
        case .index, .showConversation, .createMessage, .unreadCount, .archive, .unarchive:
            return [.scammer]
        }
    }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .index(params):
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .show(_, params):
            return try Router<APIBaseURL>.read(endpoint: endpoint, params: params).asURLRequest()
        case let .showConversation(_, params):
            return try Router<APIBaseURL>.read(endpoint: endpoint, params: params).asURLRequest()
        case let .createMessage(_, params):
            return try Router<APIBaseURL>.create(endpoint: endpoint, params: params, encoding: .url).asURLRequest()
        case .unreadCount:
            return try Router<APIBaseURL>.read(endpoint: endpoint, params: [:]).asURLRequest()
        case .archive(let params):
            return try Router<APIBaseURL>.create(endpoint: endpoint, params: params, encoding: .json).asURLRequest()
        case .unarchive(let params):
            return try Router<APIBaseURL>.batchUpdate(endpoint: endpoint, params: params, encoding: .json).asURLRequest()
        }
    }
}
