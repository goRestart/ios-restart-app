//
//  ListingApiDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 8/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
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
    
    func indexFavorites(userId: String,
                        numberOfResults: Int?,
                        resultsOffset: Int?,
                        completion: ListingsDataSourceCompletion?) {
        var params = [String: Any]()
        params["num_results"] = numberOfResults
        params["offset"] = resultsOffset
        let request = ListingRouter.indexFavorites(userId: userId, params: params)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }

    func indexRelatedListings(_ listingId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?) {
        let request = ListingRouter.indexRelatedListings(listingId: listingId, params: parameters)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }
    
    func indexRelatedRealEstate(_ listingId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?) {
        let request = ListingRouter.indexRelatedRealEstate(listingId: listingId, params: parameters)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }

    func indexDiscoverListings(_ listingId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?) {
        let request = ListingRouter.indexDiscoverListings(listingId: listingId, params: parameters)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }
    
    func indexRealEstate(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?) {
        let request = ListingRouter.indexRealEstate(params: parameters)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }
    
    func indexRealEstateRelatedSearch(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?) {
        let request = ListingRouter.indexRealEstateRelatedSearch(params: parameters)
        apiClient.request(request, decoder: ListingApiDataSource.decoderArray, completion: completion)
    }

    func retrieve(_ listingId: String, completion: ListingDataSourceCompletion?) {
        let request = ListingRouter.show(listingId: listingId)
        apiClient.request(request, decoder: ListingApiDataSource.decoder, completion: completion)
    }
    
    func retrieveRealEstate(_ listingId: String, completion: ListingDataSourceCompletion?) {
        let request = ListingRouter.showRealEstate(listingId: listingId)
        apiClient.request(request, decoder: ListingApiDataSource.decoder, completion: completion)
    }

    func createListing(userId: String, listingParams: ListingCreationParams, completion: ListingDataSourceCompletion?) {
        let request: URLRequestAuthenticable
        switch listingParams {
        case .car(let carParams):
            request = ListingRouter.create(params: carParams.apiCreationEncode(userId: userId))
            apiClient.request(request, decoder: ListingApiDataSource.carDecoder, completion: completion)
        case .product(let productParams):
            request = ListingRouter.create(params: productParams.apiCreationEncode(userId: userId))
            apiClient.request(request, decoder: ListingApiDataSource.productDecoder, completion: completion)
        case .realEstate(let realEstateParams):
            request = ListingRouter.createRealEstate(params: realEstateParams.apiCreationEncode(userId: userId))
            apiClient.request(request, decoder: ListingApiDataSource.realEstateDecoder, completion: completion)
        }
    }

    func updateListing(listingParams: ListingEditionParams, completion: ListingDataSourceCompletion?) {
        let request: URLRequestAuthenticable
        switch listingParams {
        case .car(let carParams):
            request = ListingRouter.update(listingId: carParams.carId, params: carParams.apiEditionEncode())
            apiClient.request(request, decoder: ListingApiDataSource.carDecoder, completion: completion)
        case .product(let productParams):
            request = ListingRouter.update(listingId: productParams.productId, params: productParams.apiEditionEncode())
            apiClient.request(request, decoder: ListingApiDataSource.productDecoder, completion: completion)
        case .realEstate(let realEstateParams):
            request = ListingRouter.updateRealEstate(listingId: realEstateParams.realEstateId, params: realEstateParams.apiEditionEncode())
            apiClient.request(request, decoder: ListingApiDataSource.realEstateDecoder, completion: completion)
        }
    }

    
    // MARK: Sold / unsold

    func markAsSold(_ listingId: String, completion: ListingDataSourceEmptyCompletion?) {
        var params = [String: Any]()
        params["status"] = ListingStatus.sold.apiCode
        let request = ListingRouter.patch(listingId: listingId, params: params)
        apiClient.request(request, completion: completion)
    }

    func markAsUnSold(_ listingId: String, completion: ListingDataSourceEmptyCompletion?) {
        let params: [String: Any] = ["status": ListingStatus.approved.apiCode]
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
    
    func updateStats(_ listingIds: [(listingId: String, visitSource: String, visitTimestamp: Double)],
                     action: String,
                     userId: String?,
                     completion: ListingDataSourceEmptyCompletion?) {
        let params : [String : Any] = ["productIds" : listingIds.map({ $0.listingId }),
                                       "sources": listingIds.map({ $0.visitSource }),
                                       "timestamps": listingIds.map({ $0.visitTimestamp }),
                                       "action" : action,
                                       "userId": userId ?? ""]
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
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        // Ignore listings that can't be decoded
        do {
            let listings = try JSONDecoder().decode(FailableDecodableArray<Listing>.self, from: data)
            return listings.validElements
        } catch {
            logAndReportParseError(object: object, entity: .listings,
                                   comment: "could not parse [Listing]")
        }
        return nil
    }
    
    private static func decoder(_ object: Any) -> Listing? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let listing = try Listing.decode(jsonData: data)
            return listing
        } catch {
            logAndReportParseError(object: object, entity: .listing,
                                   comment: "could not parse Listing")
        }
        return nil
    }

    private static func productDecoder(_ object: Any) -> Listing? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let product = try LGProduct.decode(jsonData: data)
            return .product(product)
        } catch {
            logAndReportParseError(object: object, entity: .product,
                                   comment: "could not parse LGProduct")
        }
        return nil
    }

    private static func carDecoder(_ object: Any) -> Listing? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let car = try LGCar.decode(jsonData: data)
            return .car(car)
        } catch {
            logAndReportParseError(object: object, entity: .car,
                                   comment: "could not parse LGCar")
        }
        return nil
    }
    
    private static func realEstateDecoder(_ object: Any) -> Listing? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let realEstate = try LGRealEstate.decode(jsonData: data)
            return .realEstate(realEstate)
        } catch {
            logAndReportParseError(object: object, entity: .realEstate,
                                   comment: "could not parse LGRealEstate")
        }
        return nil
    }

    static func decoderUserRelation(_ object: Any) -> UserListingRelation? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let relation = try LGUserListingRelation.decode(jsonData: data)
            return relation
        } catch {
            logAndReportParseError(object: object, entity: .userListingRelation,
                                   comment: "could not parse LGUserListingRelation")
        }
        return nil
    }

    static func decoderListingStats(_ object: Any) -> ListingStats? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let stats = try LGListingStats.decode(jsonData: data)
            return stats
        } catch {
            logAndReportParseError(object: object, entity: .listingStats,
                                   comment: "could not parse LGListingStats")
        }
        return nil
    }

    private static func decoderUserArray(_ object: Any) -> [UserListing]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        // Ignore user listings that can't be decoded
        do {
            let userListings = try JSONDecoder().decode(FailableDecodableArray<LGUserListing>.self, from: data)
            return userListings.validElements
        } catch {
            logAndReportParseError(object: object, entity: .listingStats,
                                   comment: "could not parse [LGUserListing]")
        }
        return nil
    }
    
    private static func decoderArrayTransactions(_ object: Any) -> [Transaction]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        // Ignore transactions that can't be decoded
        do {
            let transactions = try JSONDecoder().decode(FailableDecodableArray<LGTransaction>.self, from: data)
            return transactions.validElements
        } catch {
            logAndReportParseError(object: object, entity: .transactions,
                                   comment: "could not parse [LGTransaction]")
        }
        return nil
    }
    
    private static func decoderTransaction(_ object: Any) -> Transaction? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let transaction = try LGTransaction.decode(jsonData: data)
            return transaction
        } catch {
            logAndReportParseError(object: object, entity: .transaction,
                                   comment: "could not parse LGTransaction")
        }
        return nil
    }
}
