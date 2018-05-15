//
//  PreSignedUploadUrlRouter.swift
//  LGCoreKit
//
//  Created by Álvaro Murillo del Puerto on 12/4/18.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation
import Alamofire

enum PreSignedUploadUrlRouter: URLRequestAuthenticable {

    static let createEndPoint = "/api/pre-signed-upload-urls"

    case create(params: [String: Any])
    case upload(url: URL)

    // Mark - URLRequestAuthenticable
    var requiredAuthLevel: AuthLevel {
        switch self {
        case .create:
            return .user
        case .upload:
            return .nonexistent
        }
    }

    var endpoint: String {
        switch self {
        case .create:
            return PreSignedUploadUrlRouter.createEndPoint
        case .upload:
            return ""
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .create(params):
            return try Router<APIBaseURL>.create(endpoint: endpoint, params: params, encoding: nil).asURLRequest()
        case let .upload(url):
            // This is a special service which use a dynamic url, so we don't use Router
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = Alamofire.HTTPMethod.post.rawValue
            urlRequest.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            return urlRequest
        }
    }
}
