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

    var userObjectId: String? = nil
    let productRepository: ProductRepository
    let locationManager: LocationManager

    convenience init() {
        self.init(productRepository: Core.productRepository, locationManager: Core.locationManager)
    }

    init(productRepository: ProductRepository, locationManager: LocationManager) {
        self.productRepository = productRepository
        self.locationManager = locationManager
    }

    func canRetrieve() -> Bool { return true }
    
    func retrieveFirstPage(completion: ProductsCompletion?) {
        productsRetrieval(completion)
    }
    
    func retrieveNextPage(completion: ProductsCompletion?) {
        //User favorites doesn't have pagination.
        completion?(ProductsResult(value: []))
        return
    }

    private func productsRetrieval(completion: ProductsCompletion?) {
        guard let userId = userObjectId else { return }
        productRepository.indexFavorites(userId, completion: completion)
    }

    func isLastPage(resultCount: Int) -> Bool {
        return userObjectId != nil
    }
}


class UserStatusesProductListRequester: UserProductListRequester {

    var userObjectId: String? = nil
    private let statuses: [ProductStatus]
    private let productRepository: ProductRepository
    private let locationManager: LocationManager
    private var offset: Int = 0

    convenience init(statuses: [ProductStatus]) {
        self.init(productRepository: Core.productRepository, locationManager: Core.locationManager, statuses: statuses)
    }

    init(productRepository: ProductRepository, locationManager: LocationManager, statuses: [ProductStatus]) {
        self.productRepository = productRepository
        self.locationManager = locationManager
        self.statuses = statuses
    }

    func canRetrieve() -> Bool { return userObjectId != nil }

    func retrieveFirstPage(completion: ProductsCompletion?) {
        offset = 0
        productsRetrieval(completion)
    }
    
    func retrieveNextPage(completion: ProductsCompletion?) {
        productsRetrieval(completion)
    }
    
    private func productsRetrieval(completion: ProductsCompletion?) {
        guard let params = retrieveProductsParams else { return }
        guard let userId = userObjectId else { return  }
        productRepository.index(userId: userId, params: params, pageOffset: offset) { [weak self] result in
            if let products = result.value where !products.isEmpty {
                self?.offset += products.count
                //User posted previously -> Store it
                KeyValueStorage.sharedInstance.userPostProductPostedPreviously = true
            }
            completion?(result)
        }
    }

    func isLastPage(resultCount: Int) -> Bool {
        return resultCount == 0
    }

    private var retrieveProductsParams: RetrieveProductsParams? {
        var params: RetrieveProductsParams = RetrieveProductsParams()
        if let currentLocation = locationManager.currentLocation {
            params.coordinates = LGLocationCoordinates2D(location: currentLocation)
        }
        params.countryCode = locationManager.currentPostalAddress?.countryCode
        params.sortCriteria = .Creation
        params.statuses = statuses
        return params
    }
}
