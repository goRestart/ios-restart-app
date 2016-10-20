//
//  StickersRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

enum StickersRouter: URLRequestAuthenticable {
    
    static let stickersEndpoint = "/api/stickers"
    
    case Show(locale: String)
    
    var endpoint: String {
        return StickersRouter.stickersEndpoint
    }
    
    var requiredAuthLevel: AuthLevel {
        return .Nonexistent
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }
    
    var URLRequest: NSMutableURLRequest {
        switch self {
        case .Show(let locale):
            return Router<APIBaseURL>.Show(endpoint: endpoint, objectId: locale).URLRequest
        }
    }
}
