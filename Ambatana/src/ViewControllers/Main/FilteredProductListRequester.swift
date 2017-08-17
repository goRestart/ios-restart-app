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
    fileprivate let listingRepository: ListingRepository
    fileprivate let locationManager: LocationManager
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate var queryFirstCallCoordinates: LGLocationCoordinates2D?
    fileprivate var queryFirstCallCountryCode: String?
    fileprivate var offset: Int = 0
    fileprivate var initialOffset: Int

    var queryString: String?
    var filters: ProductFilters?

    convenience init(itemsPerPage: Int, offset: Int = 0) {
        self.init(listingRepository: Core.listingRepository, locationManager: Core.locationManager, featureFlags: FeatureFlags.sharedInstance, itemsPerPage: itemsPerPage, offset: offset)
    }

    init(listingRepository: ListingRepository, locationManager: LocationManager, featureFlags: FeatureFlaggeable, itemsPerPage: Int, offset: Int) {
        self.listingRepository = listingRepository
        self.locationManager = locationManager
        self.featureFlags = featureFlags
        self.initialOffset = offset
        self.itemsPerPage = itemsPerPage
    }


    // MARK: - ProductListRequester

    func canRetrieve() -> Bool { return queryCoordinates != nil }
    
    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?) {
        offset = initialOffset
        if let currentLocation = locationManager.currentLocation {
            queryFirstCallCoordinates = LGLocationCoordinates2D(location: currentLocation)
            queryFirstCallCountryCode = currentLocation.countryCode
        }
        
        retrieve() { [weak self] result in
            guard let indexListings = result.value, let useLimbo = self?.prependLimbo, useLimbo else {
                self?.offset = result.value?.count ?? self?.offset ?? 0
                completion?(ListingsRequesterResult(listingsResult: result, context: self?.requesterTitle, verticalTrackingInfo: self?.generateVerticalTrackingInfo()))
                return
            }
            self?.listingRepository.indexLimbo { [weak self] limboResult in
                var finalListings: [Listing] = limboResult.value ?? []
                finalListings += indexListings
                self?.offset = indexListings.count
                let listingsResult = ListingsResult(finalListings)
                completion?(ListingsRequesterResult(listingsResult: listingsResult, context: self?.requesterTitle))
            }
        }
    }
    
    func retrieveNextPage(_ completion: ListingsRequesterCompletion?) {
        retrieve() { [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(ListingsRequesterResult(listingsResult: result, context: nil))
        }
    }
    
    private func retrieve(_ completion: ListingsCompletion?) {
        listingRepository.index(retrieveProductsParams, completion: completion)
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        return resultCount == 0
    }

    func updateInitialOffset(_ newOffset: Int) {
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
        return queryFirstCallCountryCode ?? locationManager.currentLocation?.countryCode
    }

    private var requesterTitle: String? {
        guard let _ = filters?.selectedCategories.contains(.cars) else { return nil }
        var titleFromFilters: String = ""

        if let makeName = filters?.carMakeName {
            titleFromFilters += makeName
        }
        if let modelName = filters?.carModelName {
            titleFromFilters += " " + modelName
        }
        if let rangeYearTitle = rangeYearTitle(forFilters: filters) {
            titleFromFilters += " " + rangeYearTitle
        }

        let filtersHasAnyCarAttributes: Bool = filters?.carMakeId != nil ||
                                            filters?.carModelId != nil ||
                                            filters?.carYearStart != nil ||
                                            filters?.carYearEnd != nil

        if  filtersHasAnyCarAttributes && titleFromFilters.isEmpty {
            // if there's a make filter active but no title, is "Other Results"
            titleFromFilters = LGLocalizedString.filterResultsCarsOtherResults
        }

        return titleFromFilters.isEmpty ? nil : titleFromFilters.uppercase
    }

    private func rangeYearTitle(forFilters filters: ProductFilters?) -> String? {
        guard let filters = filters else { return nil }

        if let startYear = filters.carYearStart, let endYear = filters.carYearEnd, !startYear.isNegated, !endYear.isNegated {
            // both years specified
            if startYear.value == endYear.value {
                return String(startYear.value)
            } else {
                return String(startYear.value) + " - " + String(endYear.value)
            }
        } else if let startYear = filters.carYearStart, !startYear.isNegated {
            // only start specified
            if startYear.value == Date().year {
                return String(startYear.value)
            } else {
             return String(startYear.value) + " - " + String(Date().year)
            }
        } else if let endYear = filters.carYearEnd, !endYear.isNegated {
            // only end specified
            if endYear.value == Constants.filterMinCarYear {
                return String(format: LGLocalizedString.filtersCarYearBeforeYear, Constants.filterMinCarYear)
            } else {
                return String(format: LGLocalizedString.filtersCarYearBeforeYear, Constants.filterMinCarYear) + " - " + String(endYear.value)
            }
        } else {
            // no year specified
            return nil
        }
    }

    func distanceFromProductCoordinates(_ productCoords: LGLocationCoordinates2D) -> Double? {

        var meters = 0.0
        if let coordinates = queryCoordinates {
            let quadKeyStr = coordinates.coordsToQuadKey(LGCoreKitConstants.defaultQuadKeyPrecision)
            let actualQueryCoords = LGLocationCoordinates2D(fromCenterOfQuadKey: quadKeyStr)
            meters = productCoords.distanceTo(actualQueryCoords)
        }
        return meters
    }

    func isEqual(toRequester requester: ProductListRequester) -> Bool {
        guard let requester = requester as? FilteredProductListRequester else { return false }
        return queryString == requester.queryString && filters == requester.filters
    }
}


// MARK: - Private methods

fileprivate extension FilteredProductListRequester {

    var queryCoordinates: LGLocationCoordinates2D? {
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

    var retrieveProductsParams: RetrieveListingParams {
        var params: RetrieveListingParams = RetrieveListingParams()
        params.numProducts = itemsPerPage
        params.offset = offset
        params.coordinates = queryCoordinates
        params.queryString = queryString
        params.countryCode = countryCode
        params.categoryIds = filters?.selectedCategories.flatMap { $0.rawValue }
        let idCategoriesFromTaxonomies = filters?.selectedTaxonomyChildren.getIds(withType: .category)
        params.categoryIds?.append(contentsOf: idCategoriesFromTaxonomies ?? [])
        params.superKeywordIds = filters?.selectedTaxonomyChildren.getIds(withType: .superKeyword)
        
        let idSuperKeywordsFromOnboarding = filters?.onboardingFilters ?? []
        params.superKeywordIds?.append(contentsOf: idSuperKeywordsFromOnboarding)
        
        params.timeCriteria = filters?.selectedWithin
        params.sortCriteria = filters?.selectedOrdering
        params.distanceRadius = filters?.distanceRadius
        params.distanceType = filters?.distanceType
        params.makeId = filters?.carMakeId
        params.modelId = filters?.carModelId
        params.startYear = filters?.carYearStart
        params.endYear = filters?.carYearEnd
        params.abtest = featureFlags.searchParamDisc24.stringValue

        if let priceRange = filters?.priceRange {
            switch priceRange {
            case .freePrice:
                params.freePrice = true
            case let .priceRange(min, max):
                params.minPrice = min
                params.maxPrice = max
            }
        }
        return params
    }

    var prependLimbo: Bool {
        return isEmptyQueryAndDefaultFilters
    }

    var isEmptyQueryAndDefaultFilters: Bool {
        if let queryString = queryString, !queryString.isEmpty { return false }
        guard let filters = filters else { return true }
        return filters.isDefault()
    }
}

// Tracking Helpers

fileprivate extension FilteredProductListRequester {

    func generateVerticalTrackingInfo() -> VerticalTrackingInfo? {
        let vertical: ListingCategory = ListingCategory.cars
        guard let filters = filters, filters.selectedCategories.contains(vertical) else { return nil }

        var keywords: [String] = []
        var matchingFields: [String] = []
        var nonMatchingFields: [String] = []

        if let makeId = filters.carMakeId {
            keywords.append(EventParameterName.make.rawValue)
            if makeId.isNegated {
                nonMatchingFields.append(EventParameterName.make.rawValue)
            } else {
                matchingFields.append(EventParameterName.make.rawValue)
            }
        }

        if let modelId = filters.carModelId {
            keywords.append(EventParameterName.model.rawValue)
            if modelId.isNegated {
                nonMatchingFields.append(EventParameterName.model.rawValue)
            } else {
                matchingFields.append(EventParameterName.model.rawValue)
            }
        }

        if let yearStart = filters.carYearStart {
            keywords.append(EventParameterName.yearStart.rawValue)
            if yearStart.isNegated {
                nonMatchingFields.append(EventParameterName.yearStart.rawValue)
            } else {
                matchingFields.append(EventParameterName.yearStart.rawValue)
            }
        }

        if let yearEnd = filters.carYearEnd {
            keywords.append(EventParameterName.yearEnd.rawValue)
            if yearEnd.isNegated {
                nonMatchingFields.append(EventParameterName.yearEnd.rawValue)
            } else {
                matchingFields.append(EventParameterName.yearEnd.rawValue)
            }
        }

        return VerticalTrackingInfo(category: vertical, keywords: keywords, matchingFields: matchingFields, nonMatchingFields: nonMatchingFields)
    }
}

extension SearchParamDisc24 {
    var stringValue: String {
        switch self {
        case .disc24a:
            return "disc24-a"
        case .disc24b:
            return "disc24-b"
        case .disc24c:
            return "disc24-c"
        case .disc24d:
            return "disc24-d"
        case .disc24e:
            return "disc24-e"
        case .disc24f:
            return "disc24-f"
        case .disc24g:
            return "disc24-g"
        }
    }
}
