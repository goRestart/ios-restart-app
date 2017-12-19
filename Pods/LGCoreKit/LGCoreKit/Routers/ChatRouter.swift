//
//  ChatRouter.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 08/09/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

enum ChatRouter: URLRequestAuthenticable {

    case unreadCount(userId: String)

    var endpoint: String {
        switch self {
        case let .unreadCount(userId):
            return "/users/\(userId)/unread-messages"
        }
    }

    var requiredAuthLevel: AuthLevel {
        return .user
    }

    var reportingBlacklistedApiError: Array<ApiError> {
        switch self {
        case .unreadCount:
            return [.scammer]
        }
    }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case .unreadCount:
            return try Router<ChatBaseURL>.read(endpoint: endpoint, params: [:]).asURLRequest()
        }
    }
}

