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
    
    case Index
    case Show(productId: String)
    case Create(productId: String, parameters: [String: AnyObject])
    
    var endpoint: String {
        switch self {
        case .Index:
            return CommercializerRouter.videoTemplatesURL
        case .Show:
            return CommercializerRouter.productsURL
        case let .Create(productId, _):
            return CommercializerRouter.productsURL + "/\(productId)"
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Show:
            return .Installation
        case .Create, .Index:
            return .User
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        switch self {
        case .Index:
            return Router<CommercializerBaseURL>.Index(endpoint: endpoint, params: [:]).URLRequest
        case let .Show(productId):
            return Router<CommercializerBaseURL>.Show(endpoint: endpoint, objectId: productId).URLRequest
        case let .Create(_, parameters):
            return Router<CommercializerBaseURL>.Create(endpoint: endpoint, params: parameters, encoding: nil).URLRequest
        }
    }
}
