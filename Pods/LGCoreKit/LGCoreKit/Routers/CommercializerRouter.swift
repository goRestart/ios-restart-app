//
//  CommercializerRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

enum CommercializerRouter: URLRequestAuthenticable {
    
    static let videoTemplatesURL = "/api/video_templates"
    static let productsURL = "/api/products"
    
    case indexTemplates
    case index(productId: String)
    case create(productId: String, parameters: [String: Any])
    case indexAvailableProducts(userId: String)
    
    var endpoint: String {
        switch self {
        case .indexTemplates:
            return CommercializerRouter.videoTemplatesURL
        case .index:
            return CommercializerRouter.productsURL
        case let .create(productId, _):
            return CommercializerRouter.productsURL + "/\(productId)"
        case let .indexAvailableProducts(userId):
            return CommercializerRouter.productsURL + "/\(userId)" + "/user"
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        switch self {
        case .index, .indexTemplates:
            return .nonexistent
        case .create, .indexAvailableProducts:
            return .user
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .indexTemplates:
            return try Router<CommercializerBaseURL>.index(endpoint: endpoint, params: [:]).asURLRequest()
        case let .index(productId):
            return try Router<CommercializerBaseURL>.show(endpoint: endpoint, objectId: productId).asURLRequest()
        case let .create(_, parameters):
            return try Router<CommercializerBaseURL>.create(endpoint: endpoint, params: parameters, encoding: nil).asURLRequest()
        case .indexAvailableProducts:
            return try Router<CommercializerBaseURL>.index(endpoint: endpoint, params: [:]).asURLRequest()
        }
    }
}
