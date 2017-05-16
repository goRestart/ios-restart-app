//
//  FilterProductListRequesterFactory.swift
//  LetGo
//
//  Created by Dídac on 12/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class FilterProductListRequesterFactory {

    static func generateRequester(withFilters filters: ProductFilters, queryString: String?, itemsPerPage: Int) -> ProductListMultiRequester {

        var filtersArray: [ProductFilters] = [filters]
        var requestersArray: [ProductListRequester] = []

        if filters.selectedCategories.contains(.cars) {
            filtersArray = FilterProductListRequesterFactory.generateCarsNegativeFilters(fromFilters: filters)
        }

        for filter in filtersArray {
            let filteredRequester = FilteredProductListRequester(itemsPerPage: itemsPerPage, offset: 0)
            filteredRequester.filters = filter
            filteredRequester.queryString = queryString
            requestersArray.append(filteredRequester)
        }

        let multiRequester = ProductListMultiRequester(requesters: requestersArray)

        return multiRequester
    }

    private static func generateCarsNegativeFilters(fromFilters filters: ProductFilters) -> [ProductFilters] {

        var finalCarFiltersArray: [ProductFilters] = [filters]

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
