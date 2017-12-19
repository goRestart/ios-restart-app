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
    
    case show(locale: String)
    
    var endpoint: String {
        return StickersRouter.stickersEndpoint
    }
    
    var requiredAuthLevel: AuthLevel {
        return .nonexistent
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .show(let locale):
            return try Router<APIBaseURL>.show(endpoint: endpoint, objectId: locale).asURLRequest()
        }
    }
}
