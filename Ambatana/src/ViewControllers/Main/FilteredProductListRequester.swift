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
        productRepository.index(retrieveProductsParams, pageOffset: offset, completion: completion)
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
            let queryLocation = CLLocation(latitude: actualQueryCoords.latitude, longitude: actualQueryCoords.longitude)
            let productLocation = CLLocation(latitude: productCoords.latitude, longitude: productCoords.longitude)

            meters = queryLocation.distanceFromLocation(productLocation)
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

