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

    var queryString: String?
    var filters: ProductFilters?

    //Required to avoid counting limbo products from offset
    private var offsetDelta = 0
    private var prependLimbo: Bool {
        guard queryString == nil else { return false }
        guard let filters = filters else { return true }
        return filters.isDefault()
    }

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
        let realOffset = offset >= offsetDelta ? offset - offsetDelta : offset
        productRepository.index(retrieveProductsParams, pageOffset: realOffset) { [weak self] result in
            guard offset == 0, let indexProducts = result.value, useLimbo = self?.prependLimbo where useLimbo else {
                completion?(result)
                return
            }
            self?.offsetDelta = 0
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

    private var queryCoordinates: LGLocationCoordinates2D? {
        if let coordinates = filters?.place?.location {
            return coordinates
        } else if let currentLocation = locationManager.currentLocation {
            return LGLocationCoordinates2D(location: currentLocation)
        }
        return nil
    }

    private var countryCode: String? {
        if let countryCode = filters?.place?.postalAddress?.countryCode {
            return countryCode
        }
        return locationManager.currentPostalAddress?.countryCode
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
}

