//
//  ListingApiDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 8/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Argo
import Result

final class ListingApiDataSource: ListingDataSource {
    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    // MARK: Listing CRUD
    
    func index(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?) {
        let request = ListingRouter.index(params: parameters)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }
    
    func indexForUser(_ userId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?) {
        let request = ListingRouter.indexForUser(userId: userId, params: parameters)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }
    
    func indexFavorites(_ userId: String, completion: ListingsDataSourceCompletion?) {
        let request = ListingRouter.indexFavorites(userId: userId)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }

    func indexRelatedListings(_ listingId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?) {
        let request = ListingRouter.indexRelatedListings(listingId: listingId, params: parameters)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }

    func indexDiscoverListings(_ listingId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?) {
        let request = ListingRouter.indexDiscoverListings(listingId: listingId, params: parameters)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }

    func retrieve(_ listingId: String, completion: ListingDataSourceCompletion?) {
        let request = ListingRouter.show(listingId: listingId)
        apiClient.request(request, decoder: ListingApiDataSource.decoder, completion: completion)
    }
    
    func createProduct(userId: String, productParams: ProductCreationParams, completion: ProductDataSourceCompletion?) {
        let request = ListingRouter.create(params: productParams.apiCreationEncode(userId: userId))
        apiClient.request(request, decoder: ListingApiDataSource.productDecoder, completion: completion)
    }
    
    func updateProduct(productParams: ProductEditionParams, completion: ProductDataSourceCompletion?) {
        let request = ListingRouter.update(listingId: productParams.productId, params: productParams.apiEditionEncode())
        apiClient.request(request, decoder: ListingApiDataSource.productDecoder, completion: completion)
    }
    
    func createCar(userId: String, carParams: CarCreationParams, completion: CarDataSourceCompletion?) {
        let request = ListingRouter.create(params: carParams.apiCreationEncode(userId: userId))
        apiClient.request(request, decoder: ListingApiDataSource.carDecoder, completion: completion)
    }
    
    func updateCar(carParams: CarEditionParams, completion: CarDataSourceCompletion?) {
        let request = ListingRouter.update(listingId: carParams.carId, params: carParams.apiEditionEncode())
        apiClient.request(request, decoder: ListingApiDataSource.carDecoder, completion: completion)
    }

    // MARK: Sold / unsold

    func markAsSold(_ listingId: String, completion: ListingDataSourceEmptyCompletion?) {
        var params = [String: Any]()
        params["status"] = ListingStatus.sold.rawValue
        let request = ListingRouter.patch(listingId: listingId, params: params)
        apiClient.request(request, completion: completion)
    }

    func markAsUnSold(_ listingId: String, completion: ListingDataSourceEmptyCompletion?) {
        let params: [String: Any] = ["status": ListingStatus.approved.rawValue]
        let request = ListingRouter.patch(listingId: listingId, params: params)
        apiClient.request(request, completion: completion)
    }
    
    func delete(_ listingId: String, completion: ListingDataSourceEmptyCompletion?) {
        let request = ListingRouter.delete(listingId: listingId)
        apiClient.request(request, completion: completion)
    }
    
    
    // MARK: Listing-User relation
    
    func retrieveRelation(_ listingId: String, userId: String, completion: ListingDataSourceUserRelationCompletion?) {
        let request = ListingRouter.userRelation(userId: userId, listingId: listingId)
        apiClient.request(request, decoder: ListingApiDataSource.decoderUserRelation, completion: completion)
    }
    
    func saveReport(_ listingId: String, userId: String, completion: ListingDataSourceEmptyCompletion?) {
        let request = ListingRouter.saveReport(userId: userId, listingId: listingId)
        apiClient.request(request, completion: completion)
    }
    
    
    // MARK: Favorites
    
    func deleteFavorite(_ listingId: String, userId: String, completion: ListingDataSourceEmptyCompletion?) {
        let request = ListingRouter.deleteFavorite(userId: userId, listingId: listingId)
        apiClient.request(request, completion: completion)
    }
    
    func saveFavorite(_ listingId: String, userId: String, completion: ListingDataSourceEmptyCompletion?) {
        let request = ListingRouter.saveFavorite(userId: userId, listingId: listingId)
        apiClient.request(request, completion: completion)
    }


    // MARK: Limbo

    func indexLimbo(_ listingIds: [String], completion: ListingsDataSourceCompletion?) {
        let params: [String: Any] = ["ids": listingIds]
        let request = ListingRouter.indexLimbo(params: params)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }

    // MARK: Trending

    func indexTrending(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?) {
        let request = ListingRouter.indexTrending(params: parameters)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }

    // MARK: Stats

    func retrieveStats(_ listingId: String, completion: ListingDataSourceListingStatsCompletion?) {
        let request = ListingRouter.showStats(listingId: listingId, params: [:])
        apiClient.request(request, decoder: ListingApiDataSource.decoderListingStats, completion: completion)
    }
    
    func updateStats(_ listingIds: [(listingId: String, visitSource: String)], action: String, completion: ListingDataSourceEmptyCompletion?) {
        let params : [String : Any] = ["productIds" : listingIds.map({ $0.listingId }), "sources": listingIds.map({ $0.visitSource }), "action" : action]
        let request = ListingRouter.updateStats(params: params)
        apiClient.request(request, completion: completion)
    }

    // MARK: Possible buyers

    func possibleBuyersOf(listingId: String, completion: ListingDataSourceUsersCompletion?) {
        let request = ListingRouter.possibleBuyers(listingId: listingId)
        apiClient.request(request, decoder: ListingApiDataSource.decoderUserArray, completion: completion)
    }
    
    
    func createTransactionOf(createTransactionParams: CreateTransactionParams, completion: ListingDataSourceTransactionCompletion?) {
        let request = ListingRouter.createTransactionOf(listingId: createTransactionParams.listingId, params: createTransactionParams.letgoApiParams)
        apiClient.request(request, decoder: ListingApiDataSource.decoderTransaction, completion: completion)
    }
    
    func retrieveTransactionsOf(listingId: String, completion: ListingDataSourceTransactionsCompletion?) {
        let request = ListingRouter.retrieveTransactionsOf(listingId: listingId)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArrayTransactions , completion: completion)
    }

    // MARK: Decode listings
    
    private static func decoderArray(_ object: Any) -> [Listing]? {
        guard let listings: [Listing] = decode(object) else { return nil }
        return listings
    }
    
    private static func decoder(_ object: Any) -> Listing? {
        let listing: Listing? = decode(object)
        return listing
    }
    
    private static func productDecoder(_ object: Any) -> Product? {
        let product: LGProduct? = decode(object)
        return product
    }
    
    private static func carDecoder(_ object: Any) -> Car? {
        let car: LGCar? = decode(object)
        return car
    }
    
    static func decoderUserRelation(_ object: Any) -> UserListingRelation? {
        let relation: LGUserListingRelation? = decode(object)
        return relation
    }

    static func decoderListingStats(_ object: Any) -> ListingStats? {
        let stats: LGListingStats? = decode(object)
        return stats
    }

    private static func decoderUserArray(_ object: Any) -> [UserListing]? {
        guard let theUsers : [LGUserListing] = decode(object) else { return nil }
        return theUsers
    }
    
    private static func decoderArrayTransactions(_ object: Any) -> [Transaction]? {
        guard let transactions = Array<LGTransaction>.filteredDecode(JSON(object)).value else { return nil }
        return transactions.map{ $0 }
    }
    
    private static func decoderTransaction(_ object: Any) -> Transaction? {
        guard let transaction : LGTransaction = decode(object) else { return nil }
        return transaction
    }
}
