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
    let carsInfoRepository: CarsInfoRepository
    let favoritesDAO: FavoritesDAO
    let listingsLimboDAO: ListingsLimboDAO
    var viewedListings:[(listingId: String, visitSource: String)] = []

    // MARK: - Lifecycle

    init(listingDataSource: ListingDataSource,
         myUserRepository: MyUserRepository,
         favoritesDAO: FavoritesDAO,
         listingsLimboDAO: ListingsLimboDAO,
         carsInfoRepository: CarsInfoRepository) {
        self.dataSource = listingDataSource
        self.myUserRepository = myUserRepository
        self.favoritesDAO = favoritesDAO
        self.listingsLimboDAO = listingsLimboDAO
        self.viewedListings = []
        self.carsInfoRepository = carsInfoRepository
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
                    let favoritedListings = self?.setFavoritesAndCarData(value, favorites: favorites) {
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
                        newCar = self.fillCarAttributes(car: newCar)
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
        dataSource.createProduct(userId: myUserId, productParams: productParams) { [weak self] result in
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

        dataSource.updateProduct(productParams: productParams) { [weak self] result in
            if let product = result.value {
                // Send event
                self?.eventBus.onNext(.update(Listing.product(product)))
            }
            handleApiResult(result, completion: completion)
        }
    }

    func create(carParams: CarCreationParams, completion: CarCompletion?) {
        guard let myUserId = myUserRepository.myUser?.objectId else {
            completion?(CarResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        dataSource.createCar(userId: myUserId, carParams: carParams) { [weak self] result in
            guard let strongSelf = self else { return }
            if let car = result.value {
                // Cache the car in the limbo
                if let carId = car.objectId {
                    strongSelf.listingsLimboDAO.save(carId)
                }
                let newCar = LGCar(car: car)
                let carUpdated = strongSelf.fillCarAttributes(car: newCar)
                strongSelf.eventBus.onNext(.create(Listing.car(carUpdated)))
                handleApiResult(Result(value: carUpdated), completion: completion)
            } else {
                handleApiResult(result, completion: completion)
            }
        }
    }
    func update(carParams: CarEditionParams, completion: CarCompletion?) {
        guard carParams.userId == myUserRepository.myUser?.objectId else {
            completion?(CarResult(error: .internalError(message: "UserId doesn't match MyUser")))
            return
        }
        
        dataSource.updateCar(carParams: carParams) { [weak self] result in
            guard let strongSelf = self else { return }
            if let car = result.value {
                let newCar = LGCar(car: car)
                let carUpdated = strongSelf.fillCarAttributes(car: newCar)
                self?.eventBus.onNext(.update(Listing.car(carUpdated)))
                handleApiResult(Result(value: carUpdated), completion: completion)
            } else {
                handleApiResult(result, completion: completion)
            }
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

    func markAsSold(listing: Listing, completion: ListingCompletion?) {
        guard let listingId = listing.objectId else {
            completion?(ListingResult(error: .internalError(message: "Missing objectId in Listing")))
            return
        }
        dataSource.markAsSold(listingId) { [weak self] result in
            if let error = result.error {
                completion?(ListingResult(error: RepositoryError(apiError: error)))
            } else {
                self?.eventBus.onNext(.sold(listingId))
                let newListing = listing.updating(status: .sold)
                completion?(ListingResult(value: newListing))
            }
        }
    }

    func markAsUnsold(listing: Listing, completion: ListingCompletion?) {
        guard let listingId = listing.objectId else {
            completion?(ListingResult(error: .internalError(message: "Missing objectId in Listing")))
            return
        }
        dataSource.markAsUnSold(listingId) { [weak self] result in
            if let error = result.error {
                completion?(ListingResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                self?.eventBus.onNext(.unSold(listingId))
                let newListing = listing.updating(status: .approved)
                completion?(ListingResult(value: newListing))
            }
        }
    }
    
    func markAsSold(listingId: String, completion: ListingVoidCompletion?) {
        dataSource.markAsSold(listingId) { [weak self] result in
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


    // MARK: - (un)Favorite product
    
    func saveFavorite(listing: Listing, completion: ListingCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ListingResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        
        guard let listingId = listing.objectId else {
            completion?(ListingResult(error: .internalError(message: "Missing objectId in Listing")))
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
            completion?(ListingResult(error: .internalError(message: "Missing objectId in Listing")))
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
            guard let strongSelf = self else { return }
            if let error = result.error {
                completion?(ListingsResult(error: RepositoryError(apiError: error)))
            } else if let listings = result.value {
                strongSelf.listingsLimboDAO.removeAll()
                let listingIds = listings.flatMap { $0.objectId }
                self?.listingsLimboDAO.save(listingIds)

                var newListings: [Listing] = []

                for listing in listings {
                    guard let _ = listing.objectId else { continue }
                    switch listing {
                    case .product(let product):
                        newListings.append(Listing.product(product))
                    case .car(let car):
                        var newCar = LGCar(car: car)
                        newCar = strongSelf.fillCarAttributes(car: newCar)
                        newListings.append(Listing.car(newCar))
                    }
                }
                completion?(ListingsResult(value: newListings))
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

    func incrementViews(listingId: String, visitSource: String, completion: ListingVoidCompletion?) {
        viewedListings.append((listingId, visitSource))
        if viewedListings.count >= LGCoreKitConstants.viewedProductsThreshold  {
            updateListingViewsBatch(Array(viewedListings), completion: completion)
            viewedListings = []
        } else {
            completion?(ListingVoidResult(value: ()))
        }
    }

    func updateListingViewCounts() {
        guard !viewedListings.isEmpty else { return }
        updateListingViewsBatch(Array(viewedListings), completion: nil)
        viewedListings = []
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

    private func setFavoritesAndCarData(_ listings: [Listing], favorites: [String]) -> [Listing] {
        
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
                newCar = fillCarAttributes(car: newCar)
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
                let newListings = strongSelf.setFavoritesAndCarData(value, favorites: favorites)
                completion?(ListingsResult(value: newListings))
            }
        }
        return defaultCompletion
    }

    private func updateListingViewsBatch(_ listingIds: [(String, String)], completion: ListingVoidCompletion?) {
        dataSource.updateStats(listingIds, action: "incr-views") { result in
            if let error = result.error {
                completion?(ListingVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(ListingVoidResult(value: ()))
            }
        }
    }
    
    private func fillCarAttributes(car: LGCar) -> LGCar {
        guard let makeId = car.carAttributes.makeId else { return car }
        let make = carsInfoRepository.retrieveMakeName(with: makeId)
        let model = carsInfoRepository.retrieveModelName(with: makeId, modelId: car.carAttributes.modelId)
        let carAttributesUpdated = car.carAttributes.updating(makeId: car.carAttributes.makeId,
                                                              make: make,
                                                              modelId: car.carAttributes.modelId,
                                                              model: model,
                                                              year: car.carAttributes.year)
        return car.updating(carAttributes: carAttributesUpdated)
    }
}

