import LGCoreKit
import CoreLocation
import LGComponents

class FilteredListingListRequester: ListingListRequester {

    let itemsPerPage: Int
    fileprivate let listingRepository: ListingRepository
    fileprivate let locationManager: LocationManager
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate var queryFirstCallCoordinates: LGLocationCoordinates2D?
    fileprivate var queryFirstCallCountryCode: String?
    fileprivate var offset: Int = 0
    fileprivate var initialOffset: Int
    private let customFeedVariant: Int?
    private let shouldUseSimilarQuery: Bool

    var queryString: String?
    var filters: ListingFilters?

    convenience init(itemsPerPage: Int,
                     offset: Int = 0,
                     shouldUseSimilarQuery: Bool = false) {
        self.init(listingRepository: Core.listingRepository,
                  locationManager: Core.locationManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  itemsPerPage: itemsPerPage,
                  offset: offset,
                  shouldUseSimilarQuery: shouldUseSimilarQuery)
    }

    init(listingRepository: ListingRepository,
         locationManager: LocationManager,
         featureFlags: FeatureFlaggeable,
         itemsPerPage: Int,
         offset: Int,
         shouldUseSimilarQuery: Bool) {
        self.listingRepository = listingRepository
        self.locationManager = locationManager
        self.featureFlags = featureFlags
        self.initialOffset = offset
        self.itemsPerPage = itemsPerPage
        self.customFeedVariant = featureFlags.personalizedFeedABTestIntValue
        self.shouldUseSimilarQuery = shouldUseSimilarQuery
    }


    // MARK: - ListingListRequester
    
    var isFirstPage: Bool = true

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
        isFirstPage = false
        retrieve() { [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(ListingsRequesterResult(listingsResult: result, context: nil))
        }
    }
    
    private func retrieve(_ completion: ListingsCompletion?) {
        if let category = filters?.selectedCategories.first {
            let action = category.index(listingRepository: listingRepository,
                                        searchServicesEnabled: featureFlags.showServicesFeatures.isActive)
            action(retrieveListingsParams, completion)
        } else if shouldUseSimilarQuery, queryString != nil {
            listingRepository.indexSimilar(retrieveListingsParams, completion: completion)
        } else if isEmptyQueryAndDefaultFilters {
            listingRepository.indexCustomFeed(retrieveCustomFeedParams, completion: completion)
        } else {
            listingRepository.index(retrieveListingsParams, completion: completion)
        }
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        return resultCount == 0
    }

    func updateInitialOffset(_ newOffset: Int) {
        initialOffset = newOffset
    }

    func duplicate() -> ListingListRequester {
        let requester = FilteredListingListRequester(itemsPerPage: itemsPerPage)
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
        guard let filters = filters,
            filters.selectedCategories.contains(.cars) || filters.selectedTaxonomyChildren.containsCarsTaxonomy else { return nil }
        
        let carFilters = filters.verticalFilters.cars
        var titleFromFilters: String = ""

        if let makeName = carFilters.makeName {
            titleFromFilters += makeName
        }
        if let modelName = carFilters.modelName {
            titleFromFilters += " " + modelName
        }
        if let rangeYearTitle = rangeYearTitle(forCarFilters: carFilters) {
            titleFromFilters += " " + rangeYearTitle
        }

        if carFilters.hasAnyAttributesSet && titleFromFilters.isEmpty {
            // if there's a make filter active but no title, is "Other Results"
            titleFromFilters = R.Strings.filterResultsCarsOtherResults
        }

        return titleFromFilters.isEmpty ? nil : titleFromFilters.localizedUppercase
    }

    private func rangeYearTitle(forCarFilters carFilters: CarFilters) -> String? {

        if let startYear = carFilters.yearStart,
            let endYear = carFilters.yearEnd {
            // both years specified
            if startYear == endYear {
                return String(startYear)
            } else {
                return String(startYear) + " - " + String(endYear)
            }
        } else if let startYear = carFilters.yearStart {
            // only start specified
            if startYear == Date().year {
                return String(startYear)
            } else {
             return String(startYear) + " - " + String(Date().year)
            }
        } else if let endYear = carFilters.yearEnd {
            // only end specified
            if endYear == SharedConstants.filterMinCarYear {
                return R.Strings.filtersCarYearBeforeYear("\(SharedConstants.filterMinCarYear)")
            } else {
                return R.Strings.filtersCarYearBeforeYear("\(SharedConstants.filterMinCarYear)") + " - " + String(endYear)
            }
        } else {
            // no year specified
            return nil
        }
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

fileprivate extension FilteredListingListRequester {

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
        params.abtest = featureFlags.searchImprovements.stringValue
        params.relaxParam = featureFlags.relaxedSearch.relaxParam
        params.similarParam = featureFlags.emptySearchImprovements.similarParam
        params.populate(with: filters, featureFlags: featureFlags)
        return params
    }
    
    var retrieveCustomFeedParams: RetrieveListingParams {
        var params: RetrieveListingParams = RetrieveListingParams()
        params.numListings = itemsPerPage
        params.offset = offset
        params.coordinates = queryCoordinates
        params.countryCode = countryCode
        params.customFeedVariant = customFeedVariant
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

fileprivate extension FilteredListingListRequester {

    func generateVerticalTrackingInfo() -> VerticalTrackingInfo? {
        let vertical: ListingCategory = ListingCategory.cars
        guard let filters = filters, filters.selectedCategories.contains(vertical) else { return nil }

        var keywords: [String] = []
        var matchingFields: [String] = []
        
        filters.verticalFilters.createTrackingParams().forEach { (key, value) in
            let keyRaw = key.rawValue
            if let _ = value, !keywords.contains(keyRaw) { return }
            keywords.append(keyRaw)
            matchingFields.append(key.rawValue)
        }

        return VerticalTrackingInfo(category: vertical, keywords: keywords, matchingFields: matchingFields)
    }
}

extension SearchImprovements {
    var stringValue: String? {
        switch self {
        case .control, .baseline:
            return nil
        case .mWE:
            return "disc566-b"
        case .mWERelaxedSynonyms:
            return "disc566-c"
        case .mWERelaxedSynonymsMM100:
            return "disc566-d"
        case .mWERelaxedSynonymsMM75:
            return "disc566-e"
        case .mWS:
            return "disc565-a"
        case .boostingScoreDistance:
            return "disc554-a"
        case .boostingDistance:
            return "disc554-b"
        case .boostingFreshness:
            return "disc554-c"
        case .boostingDistAndFreshness:
            return "disc554-d"
        }
    }
}

private extension RelaxedSearch {
    var relaxParam: RelaxParam? {
        switch self {
        case .control, .baseline:
            return nil
        default:
            let isRelaxQuery = self == .relaxedQuery
            let includeOriginalQuery = self == .relaxedQueryORFallback
            return RelaxParam(numberOfRelaxedQueries: 1,
                              generateRelaxedQuery: isRelaxQuery,
                              includeOrInOriginalQuery: includeOriginalQuery)
        }
    }
}

private extension EmptySearchImprovements {
    
    static let maxNumberOfSimilarContexts = 10
    
    var similarParam: SimilarParam? {
        switch self {
        case .control, .baseline, .popularNearYou: return nil
        case .similarQueries, .alwaysSimilar, .similarQueriesWhenFewResults:
            return SimilarParam(numberOfSimilarContexts: EmptySearchImprovements.maxNumberOfSimilarContexts)
        }
    }
}

private extension ListingCategory {
    func index(listingRepository: ListingRepository,
               searchServicesEnabled: Bool) -> ((RetrieveListingParams, ListingsCompletion?) -> ()) {
        switch self {
        case .realEstate:
            return listingRepository.indexRealEstate
        case .cars:
            return listingRepository.indexCars
        case .services:
            return searchServicesEnabled ? listingRepository.indexServices : listingRepository.index
        case .babyAndChild, .electronics, .fashionAndAccesories, .homeAndGarden, .motorsAndAccessories,
             .moviesBooksAndMusic, .other, .sportsLeisureAndGames,
             .unassigned:
            return listingRepository.index
        }
    }
}
