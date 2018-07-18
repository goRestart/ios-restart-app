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
                                  similarSearchActive: Bool = false) -> ListingListMultiRequester {
        let requestersArray = FilterListingListRequesterFactory
            .generateRequesterArray(withFilters: filters,
                                    queryString: queryString,
                                    itemsPerPage: itemsPerPage,
                                    similarSearchActive: similarSearchActive)
        let multiRequester = ListingListMultiRequester(requesters: requestersArray)
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
    
    private static func generateRequesterArray(withFilters filters: ListingFilters,
                                               queryString: String?,
                                               itemsPerPage: Int,
                                               similarSearchActive: Bool = false) -> [ListingListRequester] {
        var requestersArray: [ListingListRequester] = []

        let filteredRequester = FilteredListingListRequester(itemsPerPage: itemsPerPage,
                                                             offset: 0,
                                                             shouldUseSimilarQuery: similarSearchActive)
        filteredRequester.filters = filters
        filteredRequester.queryString = queryString
        requestersArray.append(filteredRequester)
        
        if filters.isSearchRelatedNeeded {
            let filteredRequester = SearchRelatedListingListRequester(itemsPerPage: itemsPerPage)
            filteredRequester.filters = filters
            filteredRequester.queryString = queryString
            requestersArray.append(filteredRequester)
        }
        return requestersArray
    }
}
