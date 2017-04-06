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

typealias ListingDataSourceCompletion = (Result<Listing, ApiError>) -> Void
typealias ListingDataSourceEmptyCompletion = (Result<Void, ApiError>) -> Void

typealias ProductDataSourceCompletion = (Result<Product, ApiError>) -> Void
typealias ProductDataSourceEmptyCompletion = (Result<Void, ApiError>) -> Void

typealias CarDataSourceCompletion = (Result<Car, ApiError>) -> Void
typealias CarDataSourceEmptyCompletion = (Result<Void, ApiError>) -> Void

typealias ListingDataSourceUserRelationResult = Result<UserListingRelation, ApiError>
typealias ListingDataSourceUserRelationCompletion = (ListingDataSourceUserRelationResult) -> Void

typealias ListingDataSourceListingStatsResult = Result<ListingStats, ApiError>
typealias ListingDataSourceListingStatsCompletion = (ListingDataSourceListingStatsResult) -> Void

typealias ListingDataSourceUsersResult = Result<[UserListing], ApiError>
typealias ListingDataSourceUsersCompletion = (ListingDataSourceUsersResult) -> Void

protocol ListingDataSource {
    func index(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexForUser(_ userId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexFavorites(_ userId: String, completion: ListingsDataSourceCompletion?)
    func indexRelatedListings(_ listingId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func indexDiscoverListings(_ listingId: String, parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func retrieve(_ listingId: String, completion: ListingDataSourceCompletion?)
    func createProduct(userId: String, productParams: ProductCreationParams, completion: ProductDataSourceCompletion?)
    func updateProduct(productParams: ProductEditionParams, completion: ProductDataSourceCompletion?)
    func createCar(userId: String, carParams: CarCreationParams, completion: CarDataSourceCompletion?)
    func updateCar(carParams: CarEditionParams, completion: CarDataSourceCompletion?)
    func markAsSold(_ listingId: String, buyerId: String?, completion: ListingDataSourceEmptyCompletion?)
    func markAsUnSold(_ listingId: String, completion: ListingDataSourceEmptyCompletion?)
    func delete(_ listingId: String, completion: ListingDataSourceEmptyCompletion?)
    func deleteFavorite(_ listingId: String, userId: String, completion: ListingDataSourceEmptyCompletion?)
    func saveFavorite(_ listingId: String, userId: String, completion: ListingDataSourceEmptyCompletion?)
    func retrieveRelation(_ listingId: String, userId: String, completion: ListingDataSourceUserRelationCompletion?)
    func saveReport(_ listingId: String, userId: String, completion: ListingDataSourceEmptyCompletion?)
    func indexLimbo(_ listingIds: [String], completion: ListingsDataSourceCompletion?)
    func indexTrending(_ parameters: [String: Any], completion: ListingsDataSourceCompletion?)
    func retrieveStats(_ listingId: String, completion: ListingDataSourceListingStatsCompletion?)
    func updateStats(_ listingIds: [String], action: String, completion: ListingDataSourceEmptyCompletion?)
    func possibleBuyersOf(listingId: String, completion: ListingDataSourceUsersCompletion?)
}
