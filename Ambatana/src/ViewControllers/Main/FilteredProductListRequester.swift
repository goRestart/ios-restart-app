//
//  FilteredProductListRequester.swift
//  LetGo
//
//  Created by Eli Kohen on 20/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import CoreLocation


class FilteredProductListRequester: ProductListRequester {

    let itemsPerPage: Int
    private let productRepository: ProductRepository
    private let locationManager: LocationManager
    private var queryFirstCallCoordinates: LGLocationCoordinates2D?
    private var queryFirstCallCountryCode: String?
    private var offset: Int = 0
    private var initialOffset: Int

    var queryString: String?
    var filters: ProductFilters?

    convenience init(itemsPerPage: Int, offset: Int = 0) {
        self.init(productRepository: Core.productRepository, locationManager: Core.locationManager,
                  itemsPerPage: itemsPerPage, offset: offset)
    }

    init(productRepository: ProductRepository, locationManager: LocationManager, itemsPerPage: Int, offset: Int) {
        self.productRepository = productRepository
        self.locationManager = locationManager
        self.initialOffset = offset
        self.itemsPerPage = itemsPerPage
    }


    // MARK: - ProductListRequester

    func canRetrieve() -> Bool { return queryCoordinates != nil }
    
    
    func retrieveFirstPage(completion: ProductsCompletion?) {
        offset = initialOffset
        if let currentLocation = locationManager.currentLocation {
            queryFirstCallCoordinates = LGLocationCoordinates2D(location: currentLocation)
            queryFirstCallCountryCode = locationManager.currentPostalAddress?.countryCode
        }
        
        retrieve() { [weak self] result in
            guard let indexProducts = result.value, useLimbo = self?.prependLimbo where useLimbo else {
                self?.offset = result.value?.count ?? self?.offset ?? 0
                completion?(result)
                return
            }
            self?.productRepository.indexLimbo { [weak self] limboResult in
                var finalProducts: [Product] = limboResult.value ?? []
                finalProducts += indexProducts
                self?.offset = indexProducts.count
                completion?(ProductsResult(finalProducts))
            }
        }
    }
    
    func retrieveNextPage(completion: ProductsCompletion?) {
        retrieve() { [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(result)
        }
    }
    
    private func retrieve(completion: ProductsCompletion?) {
        productRepository.index(retrieveProductsParams, completion: completion)
    }

    func isLastPage(resultCount: Int) -> Bool {
        return resultCount == 0
    }

    func updateInitialOffset(newOffset: Int) {
        initialOffset = newOffset
    }

    func duplicate() -> ProductListRequester {
        let requester = FilteredProductListRequester(itemsPerPage: itemsPerPage)
        requester.offset = offset
        requester.queryFirstCallCoordinates = queryFirstCallCoordinates
        requester.queryFirstCallCountryCode = queryFirstCallCountryCode
        requester.queryString = queryString
        requester.filters = filters
        return requester
    }


    // MARK: - MainProductListRequester

    var countryCode: String? {
        if let countryCode = filters?.place?.postalAddress?.countryCode {
            return countryCode
        }
        return queryFirstCallCountryCode ?? locationManager.currentPostalAddress?.countryCode
    }

    func hasFilters() -> Bool {
        return filters?.selectedCategories != nil || filters?.selectedWithin != nil || filters?.distanceRadius != nil
    }

    func distanceFromProductCoordinates(productCoords: LGLocationCoordinates2D) -> Double {

        var meters = 0.0
        if let coordinates = queryCoordinates {
            let quadKeyStr = coordinates.coordsToQuadKey(LGCoreKitConstants.defaultQuadKeyPrecision)
            let actualQueryCoords = LGLocationCoordinates2D(fromCenterOfQuadKey: quadKeyStr)
            meters = productCoords.distanceTo(actualQueryCoords)
        }
        return meters
    }
}


// MARK: - Private methods

private extension FilteredProductListRequester {

    private var queryCoordinates: LGLocationCoordinates2D? {
        if let coordinates = filters?.place?.location {
            return coordinates
        } else if let firstCallCoordinates = queryFirstCallCoordinates {
            return firstCallCoordinates
        } else if let currentLocation = locationManager.currentLocation {
            // since "queryFirstCallCoordinates" is set for every first call,
            // this case shouldn't happen
            return LGLocationCoordinates2D(location: currentLocation)
        }
        return nil
    }

    private var retrieveProductsParams: RetrieveProductsParams {
        var params: RetrieveProductsParams = RetrieveProductsParams()
        params.numProducts = itemsPerPage
        params.offset = offset
        params.coordinates = queryCoordinates
        params.queryString = queryString
        params.countryCode = countryCode
        params.categoryIds = filters?.selectedCategories.flatMap{ $0.rawValue }
        params.timeCriteria = filters?.selectedWithin
        params.sortCriteria = filters?.selectedOrdering
        params.distanceRadius = filters?.distanceRadius
        params.distanceType = filters?.distanceType
        if let priceRange = filters?.priceRange {
            switch priceRange {
            case .FreePrice:
                params.freePrice = true
            case let .PriceRange(min, max):
                params.minPrice = min
                params.maxPrice = max
            }
        }
        return params
    }

    private var prependLimbo: Bool {
        return isEmptyQueryAndDefaultFilters
    }

    private var isEmptyQueryAndDefaultFilters: Bool {
        if let queryString = queryString where !queryString.isEmpty { return false }
        guard let filters = filters else { return true }
        return filters.isDefault()
    }
}
