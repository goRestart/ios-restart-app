//
//  NotificationsRouter.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


enum NotificationsRouter: URLRequestAuthenticable {

    static let notificationsEndpoint = "/api/notifications"

    case Index
    case Patch(params: [String : AnyObject])

    var endpoint: String {
        switch self {
        case .Index, .Patch:
            return NotificationsRouter.notificationsEndpoint
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Index, .Patch:
            return .User
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case .Index:
            return Router<APIBaseURL>.Index(endpoint: endpoint, params: [:]).URLRequest
        case .Patch(let params):
            return Router<APIBaseURL>.BatchPatch(endpoint: endpoint, params: params, encoding: .URL).URLRequest
        }
    }
}
