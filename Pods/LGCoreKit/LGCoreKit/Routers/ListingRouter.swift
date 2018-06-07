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
    case updateRealEstate(listingId: String, params: [String : Any])
    case patch(listingId: String, params: [String : Any])
    case show(listingId: String)
    case showRealEstate(listingId: String)
    case create(params: [String : Any])
    case createRealEstate(params: [String : Any])
    case createCar(params: [String : Any])
    case updateCar(listingId: String, params: [String : Any])
    case createServices(params: [[String : Any]])
    case updateService(listingId: String, params: [String : Any])
    case index(params: [String : Any])
    case indexRealEstate(params: [String : Any])
    case indexRealEstateRelatedSearch(params: [String : Any])
    case indexCars(params: [String : Any])
    case indexCarsRelatedSearch(params: [String : Any])
    case indexCustomFeed(params: [String : Any])
    
    case indexServices(params: [String : Any])
    case indexServicesRelatedSearch(params: [String : Any])
    
    case indexRelatedListings(listingId: String, params: [String : Any])
    case indexRelatedRealEstate(listingId: String, params: [String : Any])
    case indexRelatedCars(listingId: String, params: [String : Any])
    case indexRelatedServices(listingId: String, params: [String : Any])
    case indexDiscoverListings(listingId: String, params: [String : Any])
    case indexForUser(userId: String, params: [String : Any])
    case indexFavorites(userId: String, params: [String : Any])
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


    static let listingBaseUrl = "/api/products"
    static let listingRealEstateBaseUrl = "listings"
    static let listingCarsBaseUrl = "listings"
    static let listingServicesBaseUrl = "listings"

    var endpoint: String {
        switch self {
        case .delete, .update, .patch, .show, .create, .index, .indexCustomFeed:
            return ListingRouter.listingBaseUrl
        case .createRealEstate, .updateRealEstate:
            return ListingRouter.listingRealEstateBaseUrl
        case .createCar, .updateCar:
            return ListingRouter.listingCarsBaseUrl
        case .createServices, .updateService:
            return ListingRouter.listingServicesBaseUrl
        case .showRealEstate:
            return ListingRouter.listingRealEstateBaseUrl
        case let .indexRelatedListings(listingId, _):
            return ListingRouter.listingBaseUrl + "/\(listingId)/related"
        case let .indexRelatedRealEstate(listingId, _):
            return ListingRouter.listingRealEstateBaseUrl + "/\(listingId)/related"
        case let .indexRelatedCars(listingId, _):
            return ListingRouter.listingCarsBaseUrl + "/\(listingId)/related"
        case let .indexDiscoverListings(listingId, _):
            return ListingRouter.listingBaseUrl + "/\(listingId)/discover"
        case .indexRealEstate:
            return ListingRouter.listingRealEstateBaseUrl
        case .indexRealEstateRelatedSearch:
            return ListingRouter.listingRealEstateBaseUrl + "/related"
        case .indexCars:
            return ListingRouter.listingCarsBaseUrl
        case .indexCarsRelatedSearch:
            return ListingRouter.listingCarsBaseUrl + "/related"
        case .indexServices:
            return ListingRouter.listingServicesBaseUrl
        case .indexServicesRelatedSearch:
            return ListingRouter.listingServicesBaseUrl + "/related"
        case .indexRelatedServices(let listingId, _):
            return ListingRouter.listingServicesBaseUrl + "/\(listingId)/related"
        case let .deleteFavorite(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/favorites/products/"
        case let .saveFavorite(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/favorites/products/"
        case let .userRelation(userId, listingId):
            return ListingRouter.listingBaseUrl + "/\(listingId)/users/\(userId)"
        case let .saveReport(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/reports/products/"
        case let .indexForUser(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/products"
        case let .indexFavorites(userId, _):
            return UserRouter.userBaseUrl       + "/\(userId)/favorites/products"
        case .indexLimbo:
            return ListingRouter.listingBaseUrl + "/limbo"
        case .indexTrending:
            return ListingRouter.listingBaseUrl + "/trending"
        case let .showStats(listingId, _) :
            return ListingRouter.listingBaseUrl + "/\(listingId)/stats"
        case .updateStats(_):
            return ListingRouter.listingBaseUrl + "/stats"
        case let .possibleBuyers(listingId):
            return ListingRouter.listingBaseUrl + "/\(listingId)/conversations/users"
        case let .retrieveTransactionsOf(listingId):
            return ListingRouter.listingBaseUrl + "/\(listingId)/transactions"
        case let .createTransactionOf(listingId, _):
            return ListingRouter.listingBaseUrl + "/\(listingId)/transactions"
        }
    }

    var requiredAuthLevel: AuthLevel {
        switch self {
        case .delete, .update, .updateCar, .updateRealEstate, .patch, .create, .createRealEstate, .createCar, .createServices, .updateService, .deleteFavorite,
             .saveFavorite, .userRelation, .saveReport, .indexLimbo, .possibleBuyers, .createTransactionOf,
             .retrieveTransactionsOf:
            return .user
        case .show, .index, .showRealEstate, .indexRealEstate, .indexRealEstateRelatedSearch, .indexCars,
             .indexCarsRelatedSearch, .indexForUser, .indexFavorites, .indexRelatedListings,
             .indexRelatedRealEstate, .indexRelatedCars, .indexServices, .indexServicesRelatedSearch, .indexRelatedServices, .indexDiscoverListings, .indexTrending, .showStats,
             .updateStats, .indexCustomFeed:
            return .nonexistent
        }
    }
    
    var errorDecoderType: ErrorDecoderType? {
        return .apiProductsError
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
                                             encoding: .json).asURLRequest()
        case let .updateRealEstate(listingId, params):
            return try Router<RealEstateBaseURL>.update(endpoint: endpoint, objectId: listingId, params: params,
                                                        encoding: .json).asURLRequest()
        case let .updateService(listingId, params):
            return try Router<ServicesBaseURL>.update(endpoint: endpoint, objectId: listingId, params: params,
                                                        encoding: .json).asURLRequest()
        case let .createServices(params):
            return try Router<ServicesBaseURL>.batchCreate(endpoint: endpoint, params: params).asURLRequest()
        case let .patch(listingId, params):
            return try Router<APIBaseURL>.patch(endpoint: endpoint, objectId: listingId, params: params,
                                            encoding: .url).asURLRequest()
        case let .show(listingId):
            return try Router<APIBaseURL>.show(endpoint: endpoint, objectId: listingId).asURLRequest()
        case let .showRealEstate(listingId):
            return try Router<RealEstateBaseURL>.show(endpoint: endpoint, objectId: listingId).asURLRequest()
        case let .create(params):
            return try Router<APIBaseURL>.create(endpoint: endpoint, params: params, encoding: .json).asURLRequest()
        case let .createRealEstate(params):
            return try Router<RealEstateBaseURL>.create(endpoint: endpoint, params: params, encoding: .json).asURLRequest()
        case let .createCar(params):
            return try Router<CarsBaseURL>.create(endpoint: endpoint, params: params, encoding: .json).asURLRequest()
        case let .updateCar(listingId, params):
            return try Router<CarsBaseURL>.update(endpoint: endpoint, objectId: listingId, params: params, encoding: .json).asURLRequest()
        case let .indexRelatedListings(_, params):
            return try Router<SearchProductsBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexRelatedRealEstate(_, params):
            return try Router<SearchRealEstateBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexRelatedCars(_, params):
            return try Router<SearchCarsBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case .indexServices(let params):
            return try Router<SearchServicesBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case .indexServicesRelatedSearch(let params):
            return try Router<SearchServicesBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case .indexRelatedServices(_, let params):
            return try Router<SearchServicesBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexDiscoverListings(_, params):
            return try Router<SearchProductsBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case .userRelation(_, _):
            return try Router<APIBaseURL>.read(endpoint: endpoint, params: [:]).asURLRequest()
        case let .saveReport(_, listingId):
            return try Router<APIBaseURL>.update(endpoint: endpoint, objectId: listingId, params: [:],
                                             encoding: nil).asURLRequest()
        case let .index(params):
            return try Router<SearchProductsBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexCustomFeed(params):
            return try Router<CustomFeedBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexRealEstate(params):
            return try Router<SearchRealEstateBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexRealEstateRelatedSearch(params):
            return try Router<SearchRealEstateBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexCars(params):
            return try Router<SearchCarsBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexCarsRelatedSearch(params):
            return try Router<SearchCarsBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexForUser(_, params):
            return try Router<SearchProductsBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        case let .indexFavorites(_, params):
            return try Router<APIBaseURL>.read(endpoint: endpoint, params: params).asURLRequest()
        case let .indexLimbo(params):
            return try Router<SearchProductsBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
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
