//
//  NotificationsRouter.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


enum NotificationsRouter: URLRequestAuthenticable {

    static let notificationsEndpoint = "/notifications"

    case Index
    case UnreadCount

    var endpoint: String {
        switch self {
        case .Index:
            return NotificationsRouter.notificationsEndpoint
        case .UnreadCount:
            return NotificationsRouter.notificationsEndpoint + "/unread-count"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Index, .UnreadCount:
            return .User
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case .Index:
            return Router<NotificationsBaseURL>.Index(endpoint: endpoint, params: [:]).URLRequest
        case .UnreadCount:
            return Router<NotificationsBaseURL>.Read(endpoint: endpoint, params: [:]).URLRequest
        }
    }
}
