//
//  NotificationsRouter.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


enum NotificationsRouter: URLRequestAuthenticable {

    static let notificationsEndpoint = "/notifications"

    case index(params: [String : Any])
    case unreadCount

    var endpoint: String {
        switch self {
        case .index:
            return NotificationsRouter.notificationsEndpoint
        case .unreadCount:
            return NotificationsRouter.notificationsEndpoint + "/unread-count"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .index, .unreadCount:
            return .user
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .index(params):
            return try Router<NotificationsBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case .unreadCount:
            return try Router<NotificationsBaseURL>.read(endpoint: endpoint, params: [:]).asURLRequest()
        }
    }
}
