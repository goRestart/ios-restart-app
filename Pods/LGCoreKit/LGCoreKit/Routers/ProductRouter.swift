//
//  ProductRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 4/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation


enum ProductRouter: URLRequestAuthenticable {

    case Delete(productId: String)
    case Update(productId: String, params: [String : AnyObject])
    case Patch(productId: String, params: [String : AnyObject])
    case Show(productId: String)
    case Create(params: [String : AnyObject])
    case Index(params: [String : AnyObject])

    case IndexRelatedProducts(productId: String, params: [String : AnyObject])
    case IndexDiscoverProducts(productId: String, params: [String : AnyObject])
    case IndexForUser(userId: String, params: [String : AnyObject])
    case IndexFavorites(userId: String)
    case IndexLimbo(params: [String : AnyObject])
    case IndexTrending(params: [String : AnyObject])

    case DeleteFavorite(userId: String, productId: String)
    case SaveFavorite(userId: String, productId: String)
    case UserRelation(userId: String, productId: String)
    case SaveReport(userId: String, productId: String)

    case ShowStats(productId: String, params: [String : AnyObject])
    case UpdateStats(params: [String : AnyObject])


    static let productBaseUrl = "/api/products"

    var endpoint: String {
        switch self {
        case .Delete, .Update, .Patch, .Show, .Create, .Index:
            return ProductRouter.productBaseUrl
        case let .IndexRelatedProducts(productId, _):
            return ProductRouter.productBaseUrl + "/\(productId)/related"
        case let .IndexDiscoverProducts(productId, _):
            return ProductRouter.productBaseUrl + "/\(productId)/discover"
        case let .DeleteFavorite(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/favorites/products/"
        case let .SaveFavorite(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/favorites/products/"
        case let .UserRelation(userId, productId):
            return ProductRouter.productBaseUrl + "/\(productId)/users/\(userId)"
        case let .SaveReport(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/reports/products/"
        case let .IndexForUser(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/products"
        case let .IndexFavorites(userId):
            return UserRouter.userBaseUrl       + "/\(userId)/favorites/products"
        case .IndexLimbo:
            return ProductRouter.productBaseUrl + "/limbo"
        case .IndexTrending:
            return ProductRouter.productBaseUrl + "/trending"
        case let ShowStats(productId, _) :
            return ProductRouter.productBaseUrl + "/\(productId)/stats"
        case UpdateStats(_):
            return ProductRouter.productBaseUrl + "/stats"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .Delete, .Update, .Patch, .Create, .DeleteFavorite, .SaveFavorite, .UserRelation, .SaveReport,
             .IndexLimbo:
            return .User
        case .Show, .Index, .IndexForUser, .IndexFavorites, .IndexRelatedProducts, .IndexDiscoverProducts,
             .IndexTrending, ShowStats, UpdateStats:
            return .Installation
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.Scammer] }

    var URLRequest: NSMutableURLRequest {
        switch self {
        case let .Delete(productId):
            return Router<APIBaseURL>.Delete(endpoint: endpoint, objectId: productId).URLRequest
        case let .DeleteFavorite(_, productId):
            return Router<APIBaseURL>.Delete(endpoint: endpoint, objectId: productId).URLRequest
        case let .SaveFavorite(_, productId):
            return Router<APIBaseURL>.Update(endpoint: endpoint, objectId: productId, params: [:],
                encoding: nil).URLRequest
        case let .Update(productId, params):
            return Router<APIBaseURL>.Update(endpoint: endpoint, objectId: productId, params: params,
                encoding: .URL).URLRequest
        case let .Patch(productId, params):
            return Router<APIBaseURL>.Patch(endpoint: endpoint, objectId: productId, params: params,
                encoding: .URL).URLRequest
        case let .Show(productId):
            return Router<APIBaseURL>.Show(endpoint: endpoint, objectId: productId).URLRequest
        case let .Create(params):
            return Router<APIBaseURL>.Create(endpoint: endpoint, params: params, encoding: .URL).URLRequest
        case let .IndexRelatedProducts(_, params):
            return Router<APIBaseURL>.Index(endpoint: endpoint, params: params).URLRequest
        case let .IndexDiscoverProducts(_, params):
            return Router<APIBaseURL>.Index(endpoint: endpoint, params: params).URLRequest
        case .UserRelation(_, _):
            return Router<APIBaseURL>.Read(endpoint: endpoint, params: [:]).URLRequest
        case let .SaveReport(_, productId):
            return Router<APIBaseURL>.Update(endpoint: endpoint, objectId: productId, params: [:],
                encoding: nil).URLRequest
        case let .Index(params):
            return Router<APIBaseURL>.Index(endpoint: endpoint, params: params).URLRequest
        case let .IndexForUser(_, params):
            return Router<APIBaseURL>.Index(endpoint: endpoint, params: params).URLRequest
        case .IndexFavorites:
            return Router<APIBaseURL>.Read(endpoint: endpoint, params: [:]).URLRequest
        case let .IndexLimbo(params):
            return Router<APIBaseURL>.Index(endpoint: endpoint, params: params).URLRequest
        case let .IndexTrending(params):
            return Router<APIBaseURL>.Index(endpoint: endpoint, params: params).URLRequest
        case .ShowStats:
            return Router<APIBaseURL>.Index(endpoint: endpoint, params: [:]).URLRequest
        case let .UpdateStats(params):
            return Router<APIBaseURL>.BatchPatch(endpoint: endpoint, params: params, encoding: .URL).URLRequest
        }
    }
}
