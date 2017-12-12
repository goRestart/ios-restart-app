//
//  SearchRelatedListingListRequester.swift
//  LetGo
//
//  Created by Juan Iglesias on 11/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

class SearchRelatedListingListRequester: ListingListRequester {
    
    let itemsPerPage: Int
    fileprivate let listingRepository: ListingRepository
    fileprivate let locationManager: LocationManager
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate var queryFirstCallCoordinates: LGLocationCoordinates2D?
    fileprivate var queryFirstCallCountryCode: String?
    fileprivate var offset: Int = 0
    fileprivate var initialOffset: Int
    
    var queryString: String?
    var filters: ListingFilters?
    
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
    
    
    // MARK: - ListingListRequester
    
    func canRetrieve() -> Bool { return queryCoordinates != nil }
    
    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?) {
        offset = initialOffset
        if let currentLocation = locationManager.currentLocation {
            queryFirstCallCoordinates = LGLocationCoordinates2D(location: currentLocation)
            queryFirstCallCountryCode = currentLocation.countryCode
        }
        
        retrieve() { [weak self] result in
            self?.offset = result.value?.count ?? self?.offset ?? 0
            completion?(ListingsRequesterResult(listingsResult: result, context: self?.requesterTitle))
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
        if let categories = filters?.selectedCategories, categories.contains(.realEstate) {
            listingRepository.indexRealEstateRelatedSearch(retrieveListingsParams, completion: completion)
        }
    }
    
    func isLastPage(_ resultCount: Int) -> Bool {
        return resultCount == 0
    }
    
    func updateInitialOffset(_ newOffset: Int) {
        initialOffset = newOffset
    }
    
    func duplicate() -> ListingListRequester {
        let requester = SearchRelatedListingListRequester(itemsPerPage: itemsPerPage)
        requester.offset = offset
        requester.queryFirstCallCoordinates = queryFirstCallCoordinates
        requester.queryFirstCallCountryCode = queryFirstCallCountryCode
        requester.queryString = queryString
        requester.filters = filters
        return requester
    }
    
    
    // MARK: - MainListingListRequester
    
    var countryCode: String? {
        if let countryCode = filters?.place?.postalAddress?.countryCode {
            return countryCode
        }
        return queryFirstCallCountryCode ?? locationManager.currentLocation?.countryCode
    }
    
    private var requesterTitle: String? {
        return LGLocalizedString.realEstateRelatedSearchTitle
    }
    
    func distanceFromListingCoordinates(_ listingCoords: LGLocationCoordinates2D) -> Double? {
        
        var meters = 0.0
        if let coordinates = queryCoordinates {
            let quadKeyStr = coordinates.coordsToQuadKey(LGCoreKitConstants.defaultQuadKeyPrecision)
            let actualQueryCoords = LGLocationCoordinates2D(fromCenterOfQuadKey: quadKeyStr)
            meters = listingCoords.distanceTo(actualQueryCoords)
        }
        return meters
    }
    
    func isEqual(toRequester requester: ListingListRequester) -> Bool {
        guard let requester = requester as? FilteredListingListRequester else { return false }
        return queryString == requester.queryString && filters == requester.filters
    }
}


// MARK: - Private methods

fileprivate extension SearchRelatedListingListRequester {
    
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
    
    var retrieveListingsParams: RetrieveListingParams {
        var params: RetrieveListingParams = RetrieveListingParams()
        params.numListings = itemsPerPage
        params.offset = offset
        params.coordinates = queryCoordinates
        params.queryString = queryString
        params.countryCode = countryCode
        params.categoryIds = filters?.selectedCategories.flatMap { $0.rawValue }
        
        let idCategoriesFromTaxonomies = filters?.selectedTaxonomyChildren.getIds(withType: .category)
        params.categoryIds?.append(contentsOf: idCategoriesFromTaxonomies ?? [])
        params.superKeywordIds = filters?.selectedTaxonomyChildren.getIds(withType: .superKeyword)
        
        if let selectedTaxonomyChild = filters?.selectedTaxonomyChildren.first {
            switch selectedTaxonomyChild.type {
            case .category:
                params.categoryIds = [selectedTaxonomyChild.id]
            case .superKeyword:
                params.superKeywordIds = [selectedTaxonomyChild.id]
            }
        } else if let selectedTaxonomy = filters?.selectedTaxonomy {
            params.categoryIds = selectedTaxonomy.children.getIds(withType: .category)
            params.superKeywordIds = selectedTaxonomy.children.getIds(withType: .superKeyword)
        }
        
        params.timeCriteria = filters?.selectedWithin
        params.sortCriteria = filters?.selectedOrdering
        params.distanceRadius = filters?.distanceRadius
        params.distanceType = filters?.distanceType
        params.makeId = filters?.carMakeId
        params.modelId = filters?.carModelId
        params.startYear = filters?.carYearStart
        params.endYear = filters?.carYearEnd
        params.abtest = featureFlags.defaultRadiusDistanceFeed.stringValue
        
        if let propertyType = filters?.propertyType?.rawValue {
            params.propertyType = propertyType
        }
        if let offerType = filters?.offerType?.rawValue {
            params.offerType = offerType
        }
        params.numberOfBedrooms = filters?.numberOfBedrooms?.rawValue
        params.numberOfBathrooms = filters?.numberOfBathrooms?.rawValue
        
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
}
