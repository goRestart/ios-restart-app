//
//  FilterProductListRequesterFactory.swift
//  LetGo
//
//  Created by Dídac on 12/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

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

        // TODO: ⚠️ CHANGE THOSE NILS FOR "NEGATIVE VALUES"

        if filters.carYearStart != nil || filters.carYearEnd != nil {
            var noYearFilter = filters
            noYearFilter.carYearStart = nil
            noYearFilter.carYearEnd = nil
            finalCarFiltersArray.append(noYearFilter)
        }

        if filters.carModelId != nil {
            var noModelFilter = filters
            noModelFilter.carModelId = nil
            noModelFilter.carModelName = nil
            noModelFilter.carYearStart = nil
            noModelFilter.carYearEnd = nil
            finalCarFiltersArray.append(noModelFilter)
        }

        if filters.carMakeId != nil {
            var noMakeFilter = filters
            noMakeFilter.carMakeId = nil
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
