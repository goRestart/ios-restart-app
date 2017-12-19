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

    case upload

    static let endpoint = "/api/products/image"

    var requiredAuthLevel: AuthLevel {
        return .user
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case .upload:
            return try Router<APIBaseURL>.create(endpoint: FileRouter.endpoint, params: [:], encoding: nil).asURLRequest()
        }
    }
}
