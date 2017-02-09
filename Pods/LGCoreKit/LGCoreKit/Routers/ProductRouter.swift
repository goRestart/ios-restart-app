//
//  ProductRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 4/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation


enum ProductRouter: URLRequestAuthenticable {

    case delete(productId: String)
    case update(productId: String, params: [String : Any])
    case patch(productId: String, params: [String : Any])
    case show(productId: String)
    case create(params: [String : Any])
    case index(params: [String : Any])

    case indexRelatedProducts(productId: String, params: [String : Any])
    case indexDiscoverProducts(productId: String, params: [String : Any])
    case indexForUser(userId: String, params: [String : Any])
    case indexFavorites(userId: String)
    case indexLimbo(params: [String : Any])
    case indexTrending(params: [String : Any])

    case deleteFavorite(userId: String, productId: String)
    case saveFavorite(userId: String, productId: String)
    case userRelation(userId: String, productId: String)
    case saveReport(userId: String, productId: String)

    case showStats(productId: String, params: [String : Any])
    case updateStats(params: [String : Any])

    case possibleBuyers(productId: String)


    static let productBaseUrl = "/api/products"

    var endpoint: String {
        switch self {
        case .delete, .update, .patch, .show, .create, .index:
            return ProductRouter.productBaseUrl
        case let .indexRelatedProducts(productId, _):
            return ProductRouter.productBaseUrl + "/\(productId)/related"
        case let .indexDiscoverProducts(productId, _):
            return ProductRouter.productBaseUrl + "/\(productId)/discover"
        case let .deleteFavorite(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/favorites/products/"
        case let .saveFavorite(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/favorites/products/"
        case let .userRelation(userId, productId):
            return ProductRouter.productBaseUrl + "/\(productId)/users/\(userId)"
        case let .saveReport(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/reports/products/"
        case let .indexForUser(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/products"
        case let .indexFavorites(userId):
            return UserRouter.userBaseUrl       + "/\(userId)/favorites/products"
        case .indexLimbo:
            return ProductRouter.productBaseUrl + "/limbo"
        case .indexTrending:
            return ProductRouter.productBaseUrl + "/trending"
        case let .showStats(productId, _) :
            return ProductRouter.productBaseUrl + "/\(productId)/stats"
        case .updateStats(_):
            return ProductRouter.productBaseUrl + "/stats"
        case let .possibleBuyers(productId):
            return ProductRouter.productBaseUrl + "/\(productId)/conversations/users"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .delete, .update, .patch, .create, .deleteFavorite, .saveFavorite, .userRelation, .saveReport,
             .indexLimbo, .possibleBuyers:
            return .user
        case .show, .index, .indexForUser, .indexFavorites, .indexRelatedProducts, .indexDiscoverProducts,
             .indexTrending, .showStats, .updateStats:
            return .nonexistent
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .delete(productId):
            return try Router<APIBaseURL>.delete(endpoint: endpoint, objectId: productId).asURLRequest()
        case let .deleteFavorite(_, productId):
            return try Router<APIBaseURL>.delete(endpoint: endpoint, objectId: productId).asURLRequest()
        case let .saveFavorite(_, productId):
            return try Router<APIBaseURL>.update(endpoint: endpoint, objectId: productId, params: [:],
                                             encoding: nil).asURLRequest()
        case let .update(productId, params):
            return try Router<APIBaseURL>.update(endpoint: endpoint, objectId: productId, params: params,
                                             encoding: .url).asURLRequest()
        case let .patch(productId, params):
            return try Router<APIBaseURL>.patch(endpoint: endpoint, objectId: productId, params: params,
                                            encoding: .url).asURLRequest()
        case let .show(productId):
            return try Router<APIBaseURL>.show(endpoint: endpoint, objectId: productId).asURLRequest()
        case let .create(params):
            return try Router<APIBaseURL>.create(endpoint: endpoint, params: params, encoding: .url).asURLRequest()
        case let .indexRelatedProducts(_, params):
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexDiscoverProducts(_, params):
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case .userRelation(_, _):
            return try Router<APIBaseURL>.read(endpoint: endpoint, params: [:]).asURLRequest()
        case let .saveReport(_, productId):
            return try Router<APIBaseURL>.update(endpoint: endpoint, objectId: productId, params: [:],
                                             encoding: nil).asURLRequest()
        case let .index(params):
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexForUser(_, params):
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case .indexFavorites:
            return try Router<APIBaseURL>.read(endpoint: endpoint, params: [:]).asURLRequest()
        case let .indexLimbo(params):
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexTrending(params):
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case .showStats:
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: [:]).asURLRequest()
        case let .updateStats(params):
            return try Router<APIBaseURL>.batchPatch(endpoint: endpoint, params: params, encoding: .url).asURLRequest()
        case .possibleBuyers:
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: [:]).asURLRequest()
        }
    }
}
