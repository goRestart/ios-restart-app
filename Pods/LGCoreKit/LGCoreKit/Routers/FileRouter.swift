//
//  FileRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 4/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import Alamofire

enum FileRouter: URLRequestAuthenticable {

    case Upload

    static let endpoint = "/api/products/image"

    var requiredAuthLevel: AuthLevel {
        return .User
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case .Upload:
            return Router<APIBaseURL>.Create(endpoint: FileRouter.endpoint, params: [:], encoding: nil).URLRequest
        }
    }
}
