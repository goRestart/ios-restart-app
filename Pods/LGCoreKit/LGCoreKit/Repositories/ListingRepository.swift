//
//  ListingRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 8/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

public typealias ListingStatsResult = Result<ListingStats, RepositoryError>
public typealias ListingStatsCompletion = (ListingStatsResult) -> Void

public typealias ListingUserRelationResult = Result<UserListingRelation, RepositoryError>
public typealias ListingUserRelationCompletion = (ListingUserRelationResult) -> Void

public typealias ListingResult = Result<Listing, RepositoryError>
public typealias ListingCompletion = (ListingResult) -> Void

public typealias ProductResult = Result<Product, RepositoryError>
public typealias ProductCompletion = (ProductResult) -> Void

public typealias CarResult = Result<Car, RepositoryError>
public typealias CarCompletion = (CarResult) -> Void

public typealias ListingVoidResult = Result<Void, RepositoryError>
public typealias ListingVoidCompletion = (ListingVoidResult) -> Void

public typealias ListingsResult = Result<[Listing], RepositoryError>
public typealias ListingsCompletion = (ListingsResult) -> Void

public typealias ListingBuyersResult = Result<[UserListing], RepositoryError>
public typealias ListingBuyersCompletion = (ListingBuyersResult) -> Void

public typealias ListingTransactionsResult = Result<[Transaction], RepositoryError>
public typealias ListingTransactionsCompletion = (ListingTransactionsResult) -> Void

public typealias ListingTransactionResult = Result<Transaction, RepositoryError>
public typealias ListingTransactionCompletion = (ListingTransactionResult) -> Void


public enum ListingEvent {
    case create(Listing)
    case createListings([Listing])
    case update(Listing)
    case delete(String)
    case favorite(Listing)
    case unFavorite(Listing)
    case sold(String)
    case unSold(String)

    var listing: Listing? {
        switch self {
        case let .create(listing):
            return listing
        case let .update(listing):
            return listing
        case let .favorite(listing):
            return listing
        case let .unFavorite(listing):
            return listing
        case .delete, .sold, .unSold, .createListings:
            return nil
        }
    }
    
    var listings: [Listing]? {
        guard case .createListings(let listings) = self else { return nil }
        return listings
    }
    
    var product: Product? {
        return listing?.product
    }
    
    var car: Car? {
        return listing?.car
    }
}


public protocol ListingRepository {

    var events: Observable<ListingEvent> { get }
    func updateEvents(for listingId: String) -> Observable<Listing>

    
    // MARK: - Listing CRUD
    
    func index(_ params: RetrieveListingParams, completion: ListingsCompletion?)
    func indexSimilar(_ params: RetrieveListingParams, completion: ListingsCompletion?)
    func indexCustomFeed(_ params: RetrieveListingParams, completion: ListingsCompletion?)
    func index(userId: String, params: RetrieveListingParams, completion: ListingsCompletion?)
    func indexRelated(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?)
    
    func indexDiscover(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?)
    func indexFavorites(userId: String, numberOfResults: Int?, resultsOffset: Int?, completion: ListingsCompletion?)
    
    func indexRealEstate(_ params: RetrieveListingParams, completion: ListingsCompletion?)
    func indexRealEstateRelatedSearch(_ params: RetrieveListingParams, completion: ListingsCompletion?)
    func indexRelatedRealEstate(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?)
    
    func indexCars(_ params: RetrieveListingParams, completion: ListingsCompletion?)
    func indexCarsRelatedSearch(_ params: RetrieveListingParams, completion: ListingsCompletion?)
    func indexRelatedCars(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?)
    
    func indexServices(_ params: RetrieveListingParams, completion: ListingsCompletion?)
    func indexServicesRelatedSearch(_ params: RetrieveListingParams, completion: ListingsCompletion?)
    func indexRelatedServices(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?)
    
    func retrieve(_ listingId: String, completion: ListingCompletion?)
    func retrieveRealEstate(_ listingId: String, completion: ListingCompletion?)
    func retrieveService(_ listingId: String, completion: ListingCompletion?)
    
    func create(listingParams: ListingCreationParams, completion: ListingCompletion?)
    func update(listingParams: ListingEditionParams, completion: ListingCompletion?)
    
    func createCar(listingParams: ListingCreationParams, completion: ListingCompletion?)
    func updateCar(listingParams: ListingEditionParams, completion: ListingCompletion?)
    
    func createServices(listingParams: [ListingCreationParams], completion: ListingsCompletion?)
    func updateService(listingParams: ListingEditionParams, completion: ListingCompletion?)

    func delete(listingId: String, completion: ListingVoidCompletion?)
    
    
    // MARK: - Mark listings as (un)sold
    
    func markAsSold(listing: Listing, completion: ListingCompletion?)
    func markAsUnsold(listing: Listing, completion: ListingCompletion?)
    func markAsSold(listingId: String, completion: ListingVoidCompletion?)
    func markAsUnsold(listingId: String, completion: ListingVoidCompletion?)


    // MARK: - (un)Favorite listing
    
    func saveFavorite(listing: Listing, completion: ListingVoidCompletion?)
    func deleteFavorite(listing: Listing, completion: ListingVoidCompletion?)
    
    
    // MARK: - User-Listing relation
    
    func retrieveUserListingRelation(_ listingId: String, completion: ListingUserRelationCompletion?)
    
    
    // MARK: - Listing report

    func saveReport(_ listingId: String, completion: ListingVoidCompletion?)


    // MARK: - Listings limbo

    func indexLimbo(_ completion: ListingsCompletion?)


    // MARK: - Listing trending

    func indexTrending(_ params: IndexTrendingListingsParams, completion: ListingsCompletion?)


    // MARK: - Listing Stats

    func retrieveStats(listingId: String, completion: ListingStatsCompletion?)
    func incrementViews(listingId: String, visitSource: String, visitTimestamp: Double, completion: ListingVoidCompletion?)
    func updateListingViewCounts()

    
    // MARK: - Possible buyers

    func possibleBuyersOf(listingId: String, completion: ListingBuyersCompletion?)
    func retrieveTransactionsOf(listingId: String, completion: ListingTransactionsCompletion?)
    func createTransactionOf(createTransactionParams: CreateTransactionParams, completion: ListingTransactionCompletion?)
}
