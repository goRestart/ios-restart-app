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
    let listingsLimboDAO: ListingsLimboDAO
    let spellCorrectorRepository: SpellCorrectorRepository
    var viewedListings:[(listingId: String, visitSource: String, visitTimestamp: Double)] = []


    // MARK: - Lifecycle

    init(listingDataSource: ListingDataSource,
         myUserRepository: MyUserRepository,
         listingsLimboDAO: ListingsLimboDAO,
         carsInfoRepository: CarsInfoRepository,
         spellCorrectorRepository: SpellCorrectorRepository) {
        
        self.dataSource = listingDataSource
        self.myUserRepository = myUserRepository
        self.listingsLimboDAO = listingsLimboDAO
        self.viewedListings = []
        self.carsInfoRepository = carsInfoRepository
        self.spellCorrectorRepository = spellCorrectorRepository
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
        guard let queryString = params.queryString,
            let relaxParam = params.relaxParam else  {
                retrieveIndex(params.letgoApiParams, completion: updateCompletion(completion))
                return
        }
        retrieveIndexWithRelax(queryString, params, relaxParam, completion: completion)
    }
    
    func indexCustomFeed(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        dataSource.indexCustomFeed(params.customFeedApiParams, completion: updateCompletion(completion))
    }

    func index(userId: String, params: RetrieveListingParams, completion: ListingsCompletion?)  {
        dataSource.indexForUser(userId, parameters: params.userListingApiParams,
                                completion: updateCompletion(completion))
    }

    func indexRelated(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?)  {
        dataSource.indexRelatedListings(listingId, parameters: params.relatedProductsApiParams,
                                        completion: updateCompletion(completion))
    }
    
    func indexRelatedRealEstate(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?) {
        dataSource.indexRelatedRealEstate(listingId, parameters: params.relatedProductsApiParams,
                                          completion: updateCompletion(completion))
    }

    func indexDiscover(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?)  {
        dataSource.indexDiscoverListings(listingId, parameters: params.relatedProductsApiParams,
                                         completion: updateCompletion(completion))
    }

    func indexRealEstate(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        dataSource.indexRealEstate(params.realEstateApiParams, completion: updateCompletion(completion))
    }
    
    func indexRealEstateRelatedSearch(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        dataSource.indexRealEstateRelatedSearch(params.realEstateApiParams, completion: updateCompletion(completion))
    }
    
    func indexCars(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        dataSource.indexCars(params.carsApiParams, completion: updateCompletion(completion))
    }
    func indexCarsRelatedSearch(_ params: RetrieveListingParams, completion: ListingsCompletion?) {
        dataSource.indexCarsRelatedSearch(params.carsApiParams, completion: updateCompletion(completion))
    }
    func indexRelatedCars(listingId: String, params: RetrieveListingParams, completion: ListingsCompletion?) {
        dataSource.indexRelatedCars(listingId, parameters: params.relatedProductsApiParams,
                                          completion: updateCompletion(completion))
    }
    
    func indexFavorites(userId: String,
                        numberOfResults: Int?,
                        resultsOffset: Int?,
                        completion: ListingsCompletion?) {
        
        dataSource.indexFavorites(userId: userId, numberOfResults: numberOfResults, resultsOffset: resultsOffset) { result in
            if let value = result.value {
                completion?(ListingsResult(value: value))
            } else if let error = result.error {
                completion?(ListingsResult(error: RepositoryError(apiError: error)))
            }
        }
    }

    func retrieve(_ listingId: String, completion: ListingCompletion?) {
        dataSource.retrieve(listingId) { result in
            if let value = result.value {
                completion?(ListingResult(value: value))
            } else if let error = result.error {
                completion?(ListingResult(error: RepositoryError(apiError: error)))
            }
        }
    }
    
    func retrieveRealEstate(_ listingId: String, completion: ListingCompletion?) {
        dataSource.retrieveRealEstate(listingId) { result in
            if let value = result.value {
                completion?(ListingResult(value: value))
            } else if let error = result.error {
                completion?(ListingResult(error: RepositoryError(apiError: error)))
            }
        }
    }

    func create(listingParams: ListingCreationParams, completion: ListingCompletion?) {
        guard let myUserId = myUserRepository.myUser?.objectId else {
            completion?(ListingResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        dataSource.createListing(userId: myUserId, listingParams: listingParams) { [weak self] result in
            self?.handleCreate(result, completion)
        }
    }
    
    func createCar(listingParams: ListingCreationParams, completion: ListingCompletion?) {
        guard let myUserId = myUserRepository.myUser?.objectId else {
            completion?(ListingResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        dataSource.createListingCar(userId: myUserId, listingParams: listingParams) { [weak self] result in
            self?.handleCreate(result, completion)
        }
    }
    
    private func handleCreate(_ result: ListingDataSourceResult, _ completion: ListingCompletion?) {

        var carResult: ListingDataSourceResult?
        if var listing = result.value {
            // Cache the listing in the limbo
            if let listingId = listing.objectId {
                listingsLimboDAO.save(listingId)
            }
            if case .car(let car) = listing {
                let newCar = LGCar(car: car)
                let carUpdated = updateCarAttributes(car: newCar)
                listing = Listing.car(carUpdated)
                carResult = Result(value: listing)
            }
            // Send event
            eventBus.onNext(.create(listing))
        }
        handleApiResult(carResult ?? result, completion: completion)
    }
    
    func update(listingParams: ListingEditionParams, completion: ListingCompletion?) {
        guard listingParams.userId == myUserRepository.myUser?.objectId else {
            completion?(ListingResult(error: .internalError(message: "UserId doesn't match MyUser")))
            return
        }

        dataSource.updateListing(listingParams: listingParams) { [weak self] result in
            self?.handleUpdate(result, completion)
        }
    }
    
    func updateCar(listingParams: ListingEditionParams, completion: ListingCompletion?) {
        guard listingParams.userId == myUserRepository.myUser?.objectId else {
            completion?(ListingResult(error: .internalError(message: "UserId doesn't match MyUser")))
            return
        }
        
        dataSource.updateListingCar(listingParams: listingParams) { [weak self] result in
            self?.handleUpdate(result, completion)
        }
    }
    
    private func handleUpdate(_ result: ListingDataSourceResult, _ completion: ListingCompletion?) {
        var carResult: ListingDataSourceResult?
        if var listing = result.value {
            switch listing {
            case .car(let car):
                let newCar = LGCar(car: car)
                let carUpdated = updateCarAttributes(car: newCar)
                listing = Listing.car(carUpdated)
                carResult = Result(value: listing)
            case .product, .realEstate:
                break
            }
            // Send event
            eventBus.onNext(.update(listing))
        }
        handleApiResult(carResult ?? result, completion: completion)
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


    // MARK: - (un)Favorite listing
    
    func saveFavorite(listing: Listing, completion: ListingVoidCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ListingVoidResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        guard let listingId = listing.objectId else {
            completion?(ListingVoidResult(error: .internalError(message: "Missing objectId in Listing")))
            return
        }
        dataSource.saveFavorite(listingId, userId: userId) { [weak self] result in
            if let _ = result.value {
                self?.eventBus.onNext(.favorite(listing))
                completion?(ListingVoidResult(value: ()))
            } else if let error = result.error {
                completion?(ListingVoidResult(error: RepositoryError(apiError: error)))
            }
        }
    }
    
    func deleteFavorite(listing: Listing, completion: ListingVoidCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ListingVoidResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        guard let listingId = listing.objectId else {
            completion?(ListingVoidResult(error: .internalError(message: "Missing objectId in Listing")))
            return
        }
        dataSource.deleteFavorite(listingId, userId: userId) { [weak self] result in
            if let _ = result.value {
                self?.eventBus.onNext(.unFavorite(listing))
                completion?(ListingVoidResult(value: ()))
            } else if let error = result.error {
                completion?(ListingVoidResult(error: RepositoryError(apiError: error)))
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
            handleApiResult(result, completion: completion)
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
                    case .product, .realEstate:
                        newListings.append(listing)
                    case .car(let car):
                        let updatedCar = strongSelf.updateCarAttributes(car: car)
                        newListings.append(Listing.car(updatedCar))
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

    func incrementViews(listingId: String, visitSource: String, visitTimestamp: Double, completion: ListingVoidCompletion?) {
        viewedListings.append((listingId, visitSource, visitTimestamp))
        if viewedListings.count >= LGCoreKitConstants.viewedListingsThreshold  {
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


    // MARK: - Possible buyers & transactions

    func possibleBuyersOf(listingId: String, completion: ListingBuyersCompletion?) {
        guard let _ = myUserRepository.myUser?.objectId else {
            completion?(ListingBuyersResult(error: .internalError(message: "Not logged in")))
            return
        }
        dataSource.possibleBuyersOf(listingId: listingId) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    func retrieveTransactionsOf(listingId: String, completion: ListingTransactionsCompletion?) {
        dataSource.retrieveTransactionsOf(listingId: listingId) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    func createTransactionOf(createTransactionParams: CreateTransactionParams, completion: ListingTransactionCompletion?) {
        dataSource.createTransactionOf(createTransactionParams: createTransactionParams) { result in
            handleApiResult(result, completion: completion)
        }
    }


    // MARK: - Helpers

    private func updateCompletion(_ completion: ListingsCompletion?) -> ListingsDataSourceCompletion {
        let updatedCompletion: ListingsDataSourceCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            if let error = result.error {
                completion?(ListingsResult(error: RepositoryError(apiError: error)))
            } else if let listings = result.value {
                var updatedListings: [Listing] = []
                for listing in listings {
                    switch listing {
                    case .product, .realEstate:
                        updatedListings.append(listing)
                    case .car(let car):
                        let updatedCar = strongSelf.updateCarAttributes(car: car)
                        updatedListings.append(Listing.car(updatedCar))
                    }
                }
                completion?(ListingsResult(value: updatedListings))
            }
        }
        return updatedCompletion
    }

    private func updateListingViewsBatch(_ listingIds: [(String, String, Double)], completion: ListingVoidCompletion?) {
        let myUserId = myUserRepository.myUser?.objectId
        dataSource.updateStats(listingIds,
                               action: "incr-views",
                               userId: myUserId) { result in
            if let error = result.error {
                completion?(ListingVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(ListingVoidResult(value: ()))
            }
        }
    }
    
    private func updateCarAttributes(car: Car) -> Car {
        let mutableCar = LGCar(car: car)
        guard let makeId = car.carAttributes.makeId else { return car }
        let make = carsInfoRepository.retrieveMakeName(with: makeId)
        let model = carsInfoRepository.retrieveModelName(with: makeId, modelId: mutableCar.carAttributes.modelId)
        let carAttributesUpdated = car.carAttributes.updating(makeId: mutableCar.carAttributes.makeId,
                                                              make: make,
                                                              modelId: mutableCar.carAttributes.modelId,
                                                              model: model,
                                                              year: mutableCar.carAttributes.year)
        return mutableCar.updating(carAttributes: carAttributesUpdated)
    }
    
    private func retrieveIndexWithRelax(_ queryString: String, _ params: RetrieveListingParams, _ relaxParam: RelaxParam, completion: ListingsCompletion?) {
        spellCorrectorRepository.retrieveRelaxQuery(query: queryString, relaxParam: relaxParam) { [weak self] relaxResult in
            guard let relaxedQuery = relaxResult.value,
                relaxResult.error == nil else {
                self?.retrieveIndex(params.letgoApiParams, completion: self?.updateCompletion(completion))
                return
            }
            self?.retrieveIndex(params.letgoRelaxedApiParam(relaxQuery: relaxedQuery), completion: self?.updateCompletion(completion))
        }
    }
    
    private func retrieveIndex(_ params: [String : Any], completion: ListingsDataSourceCompletion?) {
        dataSource.index(params, completion: completion)
    }
}

private extension RetrieveListingParams {
    func letgoRelaxedApiParam(relaxQuery: RelaxQuery) -> [String : Any] {
        var apiParams = letgoApiParams
        if let relaxedQuery = relaxQuery.relaxedQuery, !relaxedQuery.isEmpty {
            apiParams["search_term"] = relaxedQuery
        }
        return apiParams
    }
}

