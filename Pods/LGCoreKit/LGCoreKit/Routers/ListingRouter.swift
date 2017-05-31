//
//  ListingRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 4/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation


enum ListingRouter: URLRequestAuthenticable {

    case delete(listingId: String)
    case update(listingId: String, params: [String : Any])
    case patch(listingId: String, params: [String : Any])
    case show(listingId: String)
    case create(params: [String : Any])
    case index(params: [String : Any])

    case indexRelatedListings(listingId: String, params: [String : Any])
    case indexDiscoverListings(listingId: String, params: [String : Any])
    case indexForUser(userId: String, params: [String : Any])
    case indexFavorites(userId: String)
    case indexLimbo(params: [String : Any])
    case indexTrending(params: [String : Any])

    case deleteFavorite(userId: String, listingId: String)
    case saveFavorite(userId: String, listingId: String)
    case userRelation(userId: String, listingId: String)
    case saveReport(userId: String, listingId: String)

    case showStats(listingId: String, params: [String : Any])
    case updateStats(params: [String : Any])

    case possibleBuyers(listingId: String)
    case retrieveTransactionsOf(listingId: String)
    case createTransactionOf(listingId: String, params: [String : Any])


    static let productBaseUrl = "/api/products"

    var endpoint: String {
        switch self {
        case .delete, .update, .patch, .show, .create, .index:
            return ListingRouter.productBaseUrl
        case let .indexRelatedListings(listingId, _):
            return ListingRouter.productBaseUrl + "/\(listingId)/related"
        case let .indexDiscoverListings(listingId, _):
            return ListingRouter.productBaseUrl + "/\(listingId)/discover"
        case let .deleteFavorite(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/favorites/products/"
        case let .saveFavorite(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/favorites/products/"
        case let .userRelation(userId, listingId):
            return ListingRouter.productBaseUrl + "/\(listingId)/users/\(userId)"
        case let .saveReport(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/reports/products/"
        case let .indexForUser(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/products"
        case let .indexFavorites(userId):
            return UserRouter.userBaseUrl       + "/\(userId)/favorites/products"
        case .indexLimbo:
            return ListingRouter.productBaseUrl + "/limbo"
        case .indexTrending:
            return ListingRouter.productBaseUrl + "/trending"
        case let .showStats(listingId, _) :
            return ListingRouter.productBaseUrl + "/\(listingId)/stats"
        case .updateStats(_):
            return ListingRouter.productBaseUrl + "/stats"
        case let .possibleBuyers(listingId):
            return ListingRouter.productBaseUrl + "/\(listingId)/conversations/users"
        case let .retrieveTransactionsOf(listingId):
            return ListingRouter.productBaseUrl + "/\(listingId)/transactions"
        case let .createTransactionOf(listingId, _):
            return ListingRouter.productBaseUrl + "/\(listingId)/transactions"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .delete, .update, .patch, .create, .deleteFavorite, .saveFavorite, .userRelation, .saveReport,
             .indexLimbo, .possibleBuyers, .createTransactionOf, .retrieveTransactionsOf:
            return .user
        case .show, .index, .indexForUser, .indexFavorites, .indexRelatedListings, .indexDiscoverListings,
             .indexTrending, .showStats, .updateStats:
            return .nonexistent
        }
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case let .delete(listingId):
            return try Router<APIBaseURL>.delete(endpoint: endpoint, objectId: listingId).asURLRequest()
        case let .deleteFavorite(_, listingId):
            return try Router<APIBaseURL>.delete(endpoint: endpoint, objectId: listingId).asURLRequest()
        case let .saveFavorite(_, listingId):
            return try Router<APIBaseURL>.update(endpoint: endpoint, objectId: listingId, params: [:],
                                             encoding: nil).asURLRequest()
        case let .update(listingId, params):
            return try Router<APIBaseURL>.update(endpoint: endpoint, objectId: listingId, params: params,
                                             encoding: .url).asURLRequest()
        case let .patch(listingId, params):
            return try Router<APIBaseURL>.patch(endpoint: endpoint, objectId: listingId, params: params,
                                            encoding: .url).asURLRequest()
        case let .show(listingId):
            return try Router<APIBaseURL>.show(endpoint: endpoint, objectId: listingId).asURLRequest()
        case let .create(params):
            return try Router<APIBaseURL>.create(endpoint: endpoint, params: params, encoding: .url).asURLRequest()
        case let .indexRelatedListings(_, params):
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexDiscoverListings(_, params):
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case .userRelation(_, _):
            return try Router<APIBaseURL>.read(endpoint: endpoint, params: [:]).asURLRequest()
        case let .saveReport(_, listingId):
            return try Router<APIBaseURL>.update(endpoint: endpoint, objectId: listingId, params: [:],
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
        case .retrieveTransactionsOf:
            return try Router<APIBaseURL>.index(endpoint: endpoint, params: [:]).asURLRequest()
        case let .createTransactionOf(_, params):
            return try Router<APIBaseURL>.create(endpoint: endpoint, params: params, encoding: .url).asURLRequest()
        }
    }
}
