//
//  ListingDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 8/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

typealias ListingsDataSourceCompletion = (Result<[Listing], ApiError>) -> Void

typealias ListingDataSourceResult = Result<Listing, ApiError>
typealias ListingDataSourceCompletion = (ListingDataSourceResult) -> Void
typealias ListingDataSourceEmptyCompletion = (Result<Void, ApiError>) -> Void

typealias ListingDataSourceUserRelationResult = Result<UserListingRelation, ApiError>
typealias ListingDataSourceUserRelationCompletion = (ListingDataSourceUserRelationResult) -> Void

typealias ListingDataSourceListingStatsResult = Result<ListingStats, ApiError>
typealias ListingDataSourceListingStatsCompletion = (ListingDataSourceListingStatsResult) -> Void

typealias ListingDataSourceUsersResult = Result<[UserListing], ApiError>
typealias ListingDataSourceUsersCompletion = (ListingDataSourceUsersResult) -> Void

typealias ListingDataSourceTransactionsResult = Result<[Transaction], ApiError>
typealias ListingDataSourceTransactionsCompletion = (ListingDataSourceTransactionsResult) -> Void

typealias ListingDataSourceTransactionResult = Result<Transaction, ApiError>
typealias ListingDataSourceTransactionCompletion = (ListingDataSourceTransactionResult) -> Void

protocol ListingDataSource {
    func index(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexCustomFeed(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexForUser(_ userId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexFavorites(userId: String, numberOfResults: Int?, resultsOffset: Int?, completion: ListingsDataSourceCompletion?)
    func indexRelatedListings(_ listingId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexDiscoverListings(_ listingId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    
    func indexRealEstate(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexRealEstateRelatedSearch(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexRelatedRealEstate(_ listingId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    
    func indexCars(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexCarsRelatedSearch(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexRelatedCars(_ listingId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    
    func indexServices(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexServicesRelatedSearch(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexRelatedServices(_ listingId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    
    func retrieve(_ listingId: String, completion: ListingDataSourceCompletion?)
    func retrieveCar(_ listingId: String, completion: ListingDataSourceCompletion?)
    func retrieveRealEstate(_ listingId: String, completion: ListingDataSourceCompletion?)
    func retrieveService(_ listingId: String, completion: ListingDataSourceCompletion?)
    
    func createListing(userId: String, listingParams: ListingCreationParams, completion: ListingDataSourceCompletion?)
    func updateListing(listingParams: ListingEditionParams, completion: ListingDataSourceCompletion?)
    
    func createListingServices(userId: String, listingParams: [ListingCreationParams], completion: ListingsDataSourceCompletion?)

    func delete(_ listingId: String, completion: ListingDataSourceEmptyCompletion?)

    func markAsSold(_ listingId: String, completion: ListingDataSourceEmptyCompletion?)
    func markAsUnSold(_ listingId: String, completion: ListingDataSourceEmptyCompletion?)

    func deleteFavorite(_ listingId: String, userId: String, completion: ListingDataSourceEmptyCompletion?)
    func saveFavorite(_ listingId: String, userId: String, completion: ListingDataSourceEmptyCompletion?)

    func retrieveRelation(_ listingId: String, userId: String, completion: ListingDataSourceUserRelationCompletion?)
    func saveReport(_ listingId: String, userId: String, completion: ListingDataSourceEmptyCompletion?)

    func indexLimbo(_ listingIds: [String], completion: ListingsDataSourceCompletion?)
    func indexTrending(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?)

    func retrieveStats(_ listingId: String, completion: ListingDataSourceListingStatsCompletion?)
    func updateStats(_ listingIds: [(listingId: String, visitSource: String, visitTimestamp: Double)],
                     action: String,
                     userId: String?,
                     completion: ListingDataSourceEmptyCompletion?)

    func possibleBuyersOf(listingId: String, completion: ListingDataSourceUsersCompletion?)

    func createTransactionOf(createTransactionParams: CreateTransactionParams, completion: ListingDataSourceTransactionCompletion?)
    func retrieveTransactionsOf(listingId: String, completion: ListingDataSourceTransactionsCompletion?)
}
