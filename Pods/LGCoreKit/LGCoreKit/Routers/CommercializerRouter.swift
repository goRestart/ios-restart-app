//
//  CommercializerRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

enum CommercializerRouter: URLRequestAuthenticable {

    static let listingsURL = "/api/products"

    case index(listingId: String)
    
    var endpoint: String {
        switch self {
        case .index:
            return CommercializerRouter.listingsURL
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
        case let .index(listingId):
            return try Router<CommercializerBaseURL>.show(endpoint: endpoint, objectId: listingId).asURLRequest()
        }
    }
}
