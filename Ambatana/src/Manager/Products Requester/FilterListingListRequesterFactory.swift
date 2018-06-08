//
//  FilterListingListRequesterFactory.swift
//  LetGo
//
//  Created by Dídac on 12/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class FilterListingListRequesterFactory {
    
    static func generateRequester(withFilters filters: ListingFilters,
                                  queryString: String?,
                                  itemsPerPage: Int,
                                  carSearchActive: Bool,
                                  similarSearchActive: Bool = false) -> ListingListMultiRequester {
        let requestersArray = FilterListingListRequesterFactory
            .generateRequesterArray(withFilters: filters,
                                    queryString: queryString,
                                    itemsPerPage: itemsPerPage,
                                    carSearchActive: carSearchActive,
                                    similarSearchActive: similarSearchActive)
        let multiRequester = ListingListMultiRequester(requesters: requestersArray)
        return multiRequester
    }
    
    static func generateCombinedSearchAndSimilar(withFilters filters: ListingFilters,
                                                 queryString: String?,
                                                 itemsPerPage: Int,
                                                 carSearchActive: Bool) -> ListingListMultiRequester {
        let similarRequesterArray = FilterListingListRequesterFactory
                                    .generateRequesterArray(withFilters: filters,
                                                            queryString: queryString,
                                                            itemsPerPage: itemsPerPage,
                                                            carSearchActive: carSearchActive,
                                                            similarSearchActive: true)
        let originalRequestersArray = FilterListingListRequesterFactory
                                    .generateRequesterArray(withFilters: filters,
                                                            queryString: queryString,
                                                            itemsPerPage: itemsPerPage,
                                                            carSearchActive: carSearchActive,
                                                            similarSearchActive: false)
        let combined = originalRequestersArray + similarRequesterArray
        let multiRequester = ListingListMultiRequester(requesters: combined)
        return multiRequester
    }
    
    /// Generate Default requester with *no filters* and *no query string*.
    ///
    /// - Parameter itemsPerPage: number of items per page in requester pagination
    /// - Returns: FilteredListingListRequester where no filter nor queries are used.
    static func generateDefaultFeedRequester(itemsPerPage: Int) -> ListingListMultiRequester {
        let requester = FilteredListingListRequester(itemsPerPage: itemsPerPage, offset: 0)
        return ListingListMultiRequester(requesters: [requester])
    }
    
    private static func generateCarsNegativeFilters(fromFilters filters: ListingFilters) -> [ListingFilters] {

        var finalCarFiltersArray: [ListingFilters] = [filters]

        if filters.carYearStart != nil || filters.carYearEnd != nil {
            var noYearFilter = filters
            if let startYear = filters.carYearStart?.value {
                noYearFilter.carYearStart = RetrieveListingParam<Int>(value: startYear, isNegated: true)
            }
            if let endYear = filters.carYearEnd?.value {
                noYearFilter.carYearEnd = RetrieveListingParam<Int>(value: endYear, isNegated: true)
            }
            finalCarFiltersArray.append(noYearFilter)
        }

        if let modelId = filters.carModelId?.value {
            var noModelFilter = filters
            noModelFilter.carModelId = RetrieveListingParam<String>(value: modelId, isNegated: true)
            noModelFilter.carModelName = nil
            noModelFilter.carYearStart = nil
            noModelFilter.carYearEnd = nil
            finalCarFiltersArray.append(noModelFilter)
        }

        if let makeId = filters.carMakeId?.value {
            var noMakeFilter = filters
            noMakeFilter.carMakeId = RetrieveListingParam<String>(value: makeId, isNegated: true)
            noMakeFilter.carMakeName = nil
            noMakeFilter.carModelId = nil
            noMakeFilter.carModelName = nil
            noMakeFilter.carYearStart = nil
            noMakeFilter.carYearEnd = nil
            finalCarFiltersArray.append(noMakeFilter)
        }

        return finalCarFiltersArray
    }
    
    private static func generateRequesterArray(withFilters filters: ListingFilters,
                                               queryString: String?,
                                               itemsPerPage: Int,
                                               carSearchActive: Bool,
                                               similarSearchActive: Bool = false) -> [ListingListRequester] {
        var filtersArray: [ListingFilters] = [filters]
        var requestersArray: [ListingListRequester] = []
        
        
        if !carSearchActive && filters.selectedCategories.contains(.cars) || filters.selectedTaxonomyChildren.containsCarsTaxonomy {
            filtersArray = FilterListingListRequesterFactory.generateCarsNegativeFilters(fromFilters: filters)
        }
        
        for filter in filtersArray {
            let filteredRequester = FilteredListingListRequester(itemsPerPage: itemsPerPage,
                                                                 offset: 0,
                                                                 shouldUseSimilarQuery: similarSearchActive)
            filteredRequester.filters = filter
            filteredRequester.queryString = queryString
            requestersArray.append(filteredRequester)
        }
        
        if filters.searchRelatedNeeded(carSearchActive: carSearchActive) {
            let filteredRequester = SearchRelatedListingListRequester(itemsPerPage: itemsPerPage)
            filteredRequester.filters = filters
            filteredRequester.queryString = queryString
            requestersArray.append(filteredRequester)
        }
        return requestersArray
    }
}
