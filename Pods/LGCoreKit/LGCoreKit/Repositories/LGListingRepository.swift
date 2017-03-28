//
//  LGListingRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift
import RxSwiftExt


final class LGListingRepository: ListingRepository {

    var events: Observable<ListingEvent> {
        return eventBus.asObservable()
    }

    private let eventBus = PublishSubject<ListingEvent>()

    let dataSource: ListingDataSource
    let myUserRepository: MyUserRepository
    let favoritesDAO: FavoritesDAO
    let listingsLimboDAO: ListingsLimboDAO
    var viewedListingIds: Set<String>


    // MARK: - Lifecycle

    init(listingDataSource: ListingDataSource,
         myUserRepository: MyUserRepository,
         favoritesDAO: FavoritesDAO,
         listingsLimboDAO: ListingsLimboDAO) {
        self.dataSource = listingDataSource
        self.myUserRepository = myUserRepository
        self.favoritesDAO = favoritesDAO
        self.listingsLimboDAO = listingsLimboDAO
        self.viewedListingIds = []
    }

    func updateEvents(for listingId: String) -> Observable<Listing> {
        let optionalListing: Observable<Listing?> = events.map {
            switch $0 {
            case .create, .delete, .favorite, .unFavorite, .sold, .unSold:
                return nil
            case let .update(listing):
                if listing.objectId == listingId {
                    return listing
                } else {
                    return nil
                }
            }
        }
        return optionalListing.unwrap()
    }


    // MARK: - Product CRUD

    func index(_ params: RetrieveListingParams, completion: ListingsCompletion?)  {
        dataSource.index(params.letgoApiParams, completion: updateCompletion(completion))
    }

    func index(userId: String, params: RetrieveListingParams, completion: ListingsCompletion?)  {
        dataSource.indexForUser(userId, parameters: params.userListingApiParams,
                                completion: updateCompletion(completion))
    }

    func indexRelated(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?)  {
        dataSource.indexRelatedListings(listingId, parameters: params.relatedProductsApiParams,
                                        completion: updateCompletion(completion))
    }

    func indexDiscover(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?)  {
        dataSource.indexDiscoverListings(listingId, parameters: params.relatedProductsApiParams,
                                         completion: updateCompletion(completion))
    }

    func indexFavorites(_ userId: String, completion: ListingsCompletion?) {

        dataSource.indexFavorites(userId) { [weak self] result in
            if let error = result.error {
                completion?(ListingsResult(error: RepositoryError(apiError: error)))
            } else if let value = result.value {
                if let myUserId = self?.myUserRepository.myUser?.objectId, myUserId == userId {
                    self?.favoritesDAO.save(listings: value)
                }
                var listings = value
                if let favorites = self?.favoritesDAO.favorites,
                    let favoritedListings = self?.setFavorites(value, favorites: favorites) {
                    listings = favoritedListings
                }
                completion?(ListingsResult(value: listings))
            }
        }
    }

    func retrieve(_ listingId: String, completion: ListingCompletion?) {
        let favorites = favoritesDAO.favorites
        dataSource.retrieve(listingId) { result in
            if let error = result.error {
                completion?(ListingResult(error: RepositoryError(apiError: error)))
            } else if let value = result.value {
                switch value {
                case .product(let product):
                    var newProduct = LGProduct(product: product)
                    if let objectId = newProduct.objectId {
                        newProduct.favorite = favorites.contains(objectId)
                    }
                    completion?(ListingResult(value: Listing.product(newProduct)))
                case .car(let car):
                    var newCar = LGCar(car: car)
                    if let objectId = newCar.objectId {
                        newCar.favorite = favorites.contains(objectId)
                    }
                    completion?(ListingResult(value: Listing.car(newCar)))
                }
            }
        }
    }

    func create(productParams: ProductCreationParams, completion: ProductCompletion?) {
        guard let myUserId = myUserRepository.myUser?.objectId else {
            completion?(ProductResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        dataSource.create(productParams: productParams.apiEncode(userId: myUserId)) { [weak self] result in

            if let product = result.value {
                // Cache the product in the limbo
                if let productId = product.objectId {
                    self?.listingsLimboDAO.save(productId)
                }
                // Send event
                self?.eventBus.onNext(.create(Listing.product(product)))
            }
            handleApiResult(result, completion: completion)
        }
    }

    func update(productParams: ProductEditionParams, completion: ProductCompletion?) {
        guard productParams.userId == myUserRepository.myUser?.objectId else {
            completion?(ProductResult(error: .internalError(message: "UserId doesn't match MyUser")))
            return
        }

        dataSource.update(productId: productParams.productId, productParams: productParams.apiEncode()) {
            [weak self] result in
            if let product = result.value {
                // Send event
                self?.eventBus.onNext(.update(Listing.product(product)))
            }
            handleApiResult(result, completion: completion)
        }
    }


    func delete(listingId: String, completion: ListingVoidCompletion?) {
        dataSource.delete(listingId) { [weak self] result in
            if let error = result.error {
                completion?(ListingVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                self?.listingsLimboDAO.remove(listingId)
                self?.eventBus.onNext(.delete(listingId))
                completion?(ListingVoidResult(value: ()))
            }
        }
    }


    // MARK: - Mark product as (un)sold

    func markAsSold(listingId: String, buyerId: String?, completion: ListingVoidCompletion?) {
        dataSource.markAsSold(listingId, buyerId: buyerId) { [weak self] result in
            if let error = result.error {
                completion?(ListingVoidResult(error: RepositoryError(apiError: error)))
            } else {
                self?.eventBus.onNext(.sold(listingId))
                completion?(ListingVoidResult(value: ()))
            }
        }
    }

    func markAsUnsold(listingId: String, completion: ListingVoidCompletion?) {
        dataSource.markAsUnSold(listingId) { [weak self] result in
            if let error = result.error {
                completion?(ListingVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                self?.eventBus.onNext(.unSold(listingId))
                completion?(ListingVoidResult(value: ()))
            }
        }
    }

    func markAsSold(product: Product, buyerId: String?, completion: ProductCompletion?) {
        
        guard let productId = product.objectId else {
            completion?(ProductResult(error: .internalError(message: "Missing objectId in Product")))
            return
        }
        
        self.markAsSold(listingId: productId, buyerId: buyerId) { result in
            if let error = result.error {
                completion?(ProductResult(error: error))
            } else {
                let newProduct = LGProduct(product: product).updating(status: .sold)
                completion?(ProductResult(value: newProduct))
            }
        }
    }
    
    func markAsUnsold(product: Product, completion: ProductCompletion?) {
        
        guard let productId = product.objectId else {
            completion?(ProductResult(error: .internalError(message: "Missing objectId in Product")))
            return
        }

        self.markAsUnsold(listingId: productId) { result in
            if let error = result.error {
                completion?(ProductResult(error: error))
            } else {
                let newProduct = LGProduct(product: product).updating(status: .approved)
                completion?(ProductResult(value: newProduct))
            }
        }
    }


    // MARK: - (un)Favorite product
    // duplicate
    func saveFavorite(listing: Listing, completion: ListingCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ListingResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        
        guard let listingId = listing.objectId else {
            completion?(ListingResult(error: .internalError(message: "Missing objectId in Product")))
            return
        }
        
        dataSource.saveFavorite(listingId, userId: userId) { [weak self] result in
            if let error = result.error {
                completion?(ListingResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                let newListing: Listing
                switch listing {
                case .product(let product):
                    var newProduct = LGProduct(product: product)
                    newProduct.favorite = true
                    newListing = .product(newProduct)
                case .car(let car):
                    var newCar = LGCar(car: car)
                    newCar.favorite = true
                    newListing = .car(newCar)
                }
                self?.favoritesDAO.save(listingId: listingId)
                self?.eventBus.onNext(.favorite(newListing))
                completion?(ListingResult(value: newListing))
            }
        }
    }
    
    func deleteFavorite(listing: Listing, completion: ListingCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ListingResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        
        guard let listingId = listing.objectId else {
            completion?(ListingResult(error: .internalError(message: "Missing objectId in Product")))
            return
        }
        
        dataSource.deleteFavorite(listingId, userId: userId)  { [weak self] result in
            if let error = result.error {
                completion?(ListingResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                let newListing: Listing
                switch listing {
                case .product(let product):
                    var newProduct = LGProduct(product: product)
                    newProduct.favorite = false
                    newListing = .product(newProduct)
                case .car(let car):
                    var newCar = LGCar(car: car)
                    newCar.favorite = false
                    newListing = .car(newCar)
                }
                self?.favoritesDAO.remove(listingId: listingId)
                self?.eventBus.onNext(.unFavorite(newListing))
                completion?(ListingResult(value: newListing))
            }
        }
    }

    // MARK: - User-Listing relation

    func retrieveUserListingRelation(_ listingId: String, completion: ListingUserRelationCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ListingUserRelationResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        dataSource.retrieveRelation(listingId, userId: userId) { result in
            handleApiResult(result, success: { [weak self] value in
                value.isFavorited ? self?.favoritesDAO.save(listingId: listingId) : self?.favoritesDAO.remove(listingId: listingId)
                }, completion: completion)
        }
    }


    // MARK: - Listing report

    func saveReport(_ listingId: String, completion: ListingVoidCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ListingVoidResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        dataSource.saveReport(listingId, userId: userId) { result in
            if let error = result.error {
                completion?(ListingVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(ListingVoidResult(value: ()))
            }
        }
    }


    // MARK: - Products limbo

    func indexLimbo(_ completion: ListingsCompletion?) {
        guard let _ = myUserRepository.myUser?.objectId else {
            completion?(Result<[Listing], RepositoryError>(value: []))
            return
        }

        let listingIds = listingsLimboDAO.listingIds
        guard !listingIds.isEmpty else {
            completion?(Result<[Listing], RepositoryError>(value: []))
            return
        }

        dataSource.indexLimbo(listingIds) { [weak self] result in
            if let error = result.error {
                completion?(ListingsResult(error: RepositoryError(apiError: error)))
            } else if let listings = result.value {
                self?.listingsLimboDAO.removeAll()
                let listingIds = listings.flatMap { $0.objectId }
                self?.listingsLimboDAO.save(listingIds)
                completion?(ListingsResult(value: listings))
            }
        }
    }


    // MARK: - Products trending

    func indexTrending(_ params: IndexTrendingListingsParams, completion: ListingsCompletion?) {
        dataSource.indexTrending(params.letgoApiParams, completion: updateCompletion(completion))
    }


    // MARK: - Listing Stats

    func retrieveStats(listingId: String, completion: ListingStatsCompletion?) {
        dataSource.retrieveStats(listingId) { result in
            if let error = result.error {
                completion?(ListingStatsResult(error: RepositoryError(apiError: error)))
            } else if let stats = result.value {
                completion?(ListingStatsResult(value: stats))
            }
        }
    }

    func incrementViews(listingId: String, completion: ListingVoidCompletion?) {
        viewedListingIds.insert(listingId)
        if viewedListingIds.count >= LGCoreKitConstants.viewedProductsThreshold  {
            updateListingViewsBatch(Array(viewedListingIds), completion: completion)
            viewedListingIds = []
        } else {
            completion?(ListingVoidResult(value: ()))
        }
    }

    func updateListingViewCounts() {
        guard !viewedListingIds.isEmpty else { return }
        updateListingViewsBatch(Array(viewedListingIds), completion: nil)
        viewedListingIds = []
    }


    // MARK: - Possible buyers

    func possibleBuyersOf(listingId: String, completion: ListingBuyersCompletion?) {
        guard let _ = myUserRepository.myUser?.objectId else {
            completion?(ListingBuyersResult(error: .internalError(message: "Not logged in")))
            return
        }
        dataSource.possibleBuyersOf(listingId: listingId) { result in
            handleApiResult(result, completion: completion)
        }
    }


    // MARK: - Private funcs

    private func setFavorites(_ listings: [Listing], favorites: [String]) -> [Listing] {
        
        var newListings: [Listing] = []
        
        for listing in listings {
            guard let listingId = listing.objectId else { continue }
            switch listing {
            case .product(let product):
                var newProduct = LGProduct(product: product)
                newProduct.favorite = favorites.contains(listingId)
                newListings.append(Listing.product(newProduct))
            case .car(let car):
                var newCar = LGCar(car: car)
                newCar.favorite = favorites.contains(listingId)
                newListings.append(Listing.car(newCar))
            }
        }
        return newListings
    }

    private func updateCompletion(_ completion: ListingsCompletion?) -> ListingsDataSourceCompletion {
        let favorites = favoritesDAO.favorites
        let defaultCompletion: ListingsDataSourceCompletion = { [weak self] result in
            if let error = result.error {
                completion?(ListingsResult(error: RepositoryError(apiError: error)))
            } else if let value = result.value {
                guard let strongSelf = self else { return }
                let newListings = strongSelf.setFavorites(value, favorites: favorites)
                completion?(ListingsResult(value: newListings))
            }
        }
        return defaultCompletion
    }

    private func updateListingViewsBatch(_ listingIds: [String], completion: ListingVoidCompletion?) {
        dataSource.updateStats(listingIds, action: "incr-views") { result in
            if let error = result.error {
                completion?(ListingVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(ListingVoidResult(value: ()))
            }
        }
    }
}

