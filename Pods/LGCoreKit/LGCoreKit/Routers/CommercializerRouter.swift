//
//  CommercializerRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

enum CommercializerRouter: URLRequestAuthenticable {

    static let productsURL = "/api/products"

    case index(productId: String)
    
    var endpoint: String {
        switch self {
        case .index:
            return CommercializerRouter.productsURL
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        switch self {
        case .index:
            return .nonexistent
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .index(productId):
            return try Router<CommercializerBaseURL>.show(endpoint: endpoint, objectId: productId).asURLRequest()
        }
    }
}
