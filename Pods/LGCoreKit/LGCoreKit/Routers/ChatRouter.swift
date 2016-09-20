//
//  ChatRouter.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 08/09/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

enum ChatRouter: URLRequestAuthenticable {

    case UnreadCount(userId: String)

    var endpoint: String {
        switch self {
        case let .UnreadCount(userId):
            return "/users/\(userId)/unread-messages"
        }
    }

    var requiredAuthLevel: AuthLevel {
        return .User
    }

    var reportingBlacklistedApiError: Array<ApiError> {
        switch self {
        case .UnreadCount:
            return [.Scammer]
        }
    }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case .UnreadCount:
            return Router<ChatBaseURL>.Read(endpoint: endpoint, params: [:]).URLRequest
        }
    }
}

