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
    
    case IndexTemplates
    case Index(productId: String)
    case Create(productId: String, parameters: [String: AnyObject])
    
    var endpoint: String {
        switch self {
        case .IndexTemplates:
            return CommercializerRouter.videoTemplatesURL
        case .Index:
            return CommercializerRouter.productsURL
        case let .Create(productId, _):
            return CommercializerRouter.productsURL + "/\(productId)"
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Index, .IndexTemplates:
            return .Installation
        case .Create:
            return .User
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        switch self {
        case .IndexTemplates:
            return Router<CommercializerBaseURL>.Index(endpoint: endpoint, params: [:]).URLRequest
        case let .Index(productId):
            return Router<CommercializerBaseURL>.Show(endpoint: endpoint, objectId: productId).URLRequest
        case let .Create(_, parameters):
            return Router<CommercializerBaseURL>.Create(endpoint: endpoint, params: parameters, encoding: nil).URLRequest
        }
    }
}
