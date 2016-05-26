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

    private let productRepository: ProductRepository
    private let locationManager: LocationManager
    private var queryFirstCallCoordinates: LGLocationCoordinates2D?
    private var queryFirstCallCountryCode: String?

    var queryString: String?
    var filters: ProductFilters?

    //Required to avoid counting limbo products from offset
    private var offsetDelta = 0

    convenience init() {
        self.init(productRepository: Core.productRepository, locationManager: Core.locationManager)
    }

    init(productRepository: ProductRepository, locationManager: LocationManager) {
        self.productRepository = productRepository
        self.locationManager = locationManager
    }


    // MARK: - ProductListRequester

    func canRetrieve() -> Bool { return queryCoordinates != nil }

    func productsRetrieval(offset offset: Int, completion: ProductsCompletion?) {
        if offset == 0 {
            offsetDelta = 0
            if let currentLocation = locationManager.currentLocation {
                queryFirstCallCoordinates = LGLocationCoordinates2D(location: currentLocation)
                queryFirstCallCountryCode = locationManager.currentPostalAddress?.countryCode
            }
        }

        let indexCompletion: ProductsCompletion = { [weak self] result in
            guard offset == 0, let indexProducts = result.value, useLimbo = self?.prependLimbo where useLimbo else {
                completion?(result)
                return
            }
            self?.productRepository.indexLimbo { [weak self] limboResult in
                let finalProducts: [Product]
                if let limboProducts = limboResult.value {
                    self?.offsetDelta = limboProducts.count
                    finalProducts = limboProducts + indexProducts
                } else {
                    finalProducts = indexProducts
                }
                completion?(ProductsResult(finalProducts))
            }
        }

        let realOffset = offset >= offsetDelta ? offset - offsetDelta : offset

        if shouldIndexProductTrending {
            let params = IndexTrendingProductsParams(countryCode: countryCode, coordinates: queryCoordinates,
                                                     offset: realOffset)
            productRepository.indexTrending(params, completion: indexCompletion)

        } else {
            productRepository.index(retrieveProductsParams, pageOffset: realOffset, completion: indexCompletion)
        }
    }

    func isLastPage(resultCount: Int) -> Bool { return resultCount == 0 }


    // MARK: - MainProductListRequester

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

        let distanceType = DistanceType.systemDistanceType()
        switch (distanceType) {
        case .Km:
            return meters * 0.001
        case .Mi:
            return meters * 0.000621371
        }
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

    private var countryCode: String? {
        if let countryCode = filters?.place?.postalAddress?.countryCode {
            return countryCode
        }
        return queryFirstCallCountryCode ?? locationManager.currentPostalAddress?.countryCode
    }

    private var retrieveProductsParams: RetrieveProductsParams {
        var params: RetrieveProductsParams = RetrieveProductsParams()
        params.coordinates = queryCoordinates
        params.queryString = queryString
        params.countryCode = countryCode
        params.categoryIds = filters?.selectedCategories.map{ $0.rawValue }
        params.timeCriteria = filters?.selectedWithin
        params.sortCriteria = filters?.selectedOrdering
        params.distanceRadius = filters?.distanceRadius
        params.distanceType = filters?.distanceType
        return params
    }

    private var prependLimbo: Bool {
        return isEmptyQueryAndDefaultFilters
    }

    private var shouldIndexProductTrending: Bool {
        guard let firstOpenDate = KeyValueStorage.sharedInstance[.firstRunDate] else { return false }
        guard isEmptyQueryAndDefaultFilters else { return false }
        return FeatureFlags.indexProductsTrendingFirst24h && NSDate().timeIntervalSinceDate(firstOpenDate) <= 86400
    }

    private var isEmptyQueryAndDefaultFilters: Bool {
        if let queryString = queryString where !queryString.isEmpty { return false }
        guard let filters = filters else { return true }
        return filters.isDefault()
    }
}
