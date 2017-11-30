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

    static func generateRequester(withFilters filters: ListingFilters, queryString: String?, itemsPerPage: Int, multiRequesterEnabled: Bool) -> ListingListMultiRequester {

        var filtersArray: [ListingFilters] = [filters]
        var requestersArray: [ListingListRequester] = []

        if multiRequesterEnabled && (filters.selectedCategories.contains(.cars) || filters.selectedTaxonomyChildren.containsCarsTaxonomy) {
            filtersArray = FilterListingListRequesterFactory.generateCarsNegativeFilters(fromFilters: filters)
        }

        for filter in filtersArray {
            let filteredRequester = FilteredListingListRequester(itemsPerPage: itemsPerPage, offset: 0)
            filteredRequester.filters = filter
            filteredRequester.queryString = queryString
            requestersArray.append(filteredRequester)
        }

        let multiRequester = ListingListMultiRequester(requesters: requestersArray)

        return multiRequester
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
}
