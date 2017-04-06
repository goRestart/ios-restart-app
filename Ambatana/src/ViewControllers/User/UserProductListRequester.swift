//
//  UserProductListRequester.swift
//  LetGo
//
//  Created by Eli Kohen on 19/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol UserProductListRequester: ProductListRequester {
    var userObjectId: String? { get set }
}

class UserFavoritesProductListRequester: UserProductListRequester {

    let itemsPerPage: Int = 0 // Not used, favorites doesn't paginate
    var userObjectId: String? = nil
    let listingRepository: ListingRepository
    let locationManager: LocationManager

    convenience init() {
        self.init(listingRepository: Core.listingRepository, locationManager: Core.locationManager)
    }

    init(listingRepository: ListingRepository, locationManager: LocationManager) {
        self.listingRepository = listingRepository
        self.locationManager = locationManager
    }

    func canRetrieve() -> Bool { return true }
    
    func retrieveFirstPage(_ completion: ListingsCompletion?) {
        productsRetrieval(completion)
    }
    
    func retrieveNextPage(_ completion: ListingsCompletion?) {
        //User favorites doesn't have pagination.
        completion?(ListingsResult(value: []))
        return
    }

    private func productsRetrieval(_ completion: ListingsCompletion?) {
        guard let userId = userObjectId else { return }
        listingRepository.indexFavorites(userId, completion: completion)
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        // favorites has no pagination
        return true
    }

    func updateInitialOffset(_ newOffset: Int) { }

    func duplicate() -> ProductListRequester {
        let r = UserFavoritesProductListRequester()
        r.userObjectId = userObjectId
        return r
    }
}


class UserStatusesProductListRequester: UserProductListRequester {

    let itemsPerPage: Int
    var userObjectId: String? = nil
    private let statuses: [ListingStatus]
    private let listingRepository: ListingRepository
    private let locationManager: LocationManager
    private var offset: Int = 0

    convenience init(statuses: [ListingStatus], itemsPerPage: Int) {
        self.init(listingRepository: Core.listingRepository, locationManager: Core.locationManager, statuses: statuses,
                  itemsPerPage: itemsPerPage)
    }

    init(listingRepository: ListingRepository, locationManager: LocationManager, statuses: [ListingStatus],
         itemsPerPage: Int) {
        self.listingRepository = listingRepository
        self.locationManager = locationManager
        self.statuses = statuses
        self.itemsPerPage = itemsPerPage
    }

    func canRetrieve() -> Bool { return userObjectId != nil }

    func retrieveFirstPage(_ completion: ListingsCompletion?) {
        offset = 0
        productsRetrieval(completion)
    }
    
    func retrieveNextPage(_ completion: ListingsCompletion?) {
        productsRetrieval(completion)
    }
    
    private func productsRetrieval(_ completion: ListingsCompletion?) {
        guard let userId = userObjectId else { return  }
        listingRepository.index(userId: userId, params: retrieveProductsParams) { [weak self] result in
            if let products = result.value, !products.isEmpty {
                self?.offset += products.count
                //User posted previously -> Store it
                KeyValueStorage.sharedInstance.userPostProductPostedPreviously = true
            }
            completion?(result)
        }
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        return resultCount == 0
    }

    func updateInitialOffset(_ newOffset: Int) { }

    func duplicate() -> ProductListRequester {
        let r = UserStatusesProductListRequester(statuses: statuses, itemsPerPage: itemsPerPage)
        r.offset = offset
        r.userObjectId = userObjectId
        return r
    }

    private var retrieveProductsParams: RetrieveListingParams {
        var params: RetrieveListingParams = RetrieveListingParams()
        params.offset = offset
        params.numProducts = itemsPerPage
        if let currentLocation = locationManager.currentLocation {
            params.coordinates = LGLocationCoordinates2D(location: currentLocation)
        }
        params.countryCode = locationManager.currentLocation?.countryCode
        params.sortCriteria = .creation
        params.statuses = statuses
        return params
    }
}
