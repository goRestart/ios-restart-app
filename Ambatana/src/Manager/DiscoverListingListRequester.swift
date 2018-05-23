//
//  DiscoverListingListRequester.swift
//  LetGo
//
//  Created by Albert Hernández López on 14/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class DiscoverListingListRequester {
    let itemsPerPage: Int
    fileprivate let listingObjectId: String
    fileprivate let listingRepository: ListingRepository
    fileprivate var offset: Int = 0

    convenience init(listingId: String, itemsPerPage: Int) {
        self.init(listingId: listingId, itemsPerPage: itemsPerPage, listingRepository: Core.listingRepository)
    }

    init(listingId: String, itemsPerPage: Int, listingRepository: ListingRepository) {
        self.listingObjectId = listingId
        self.listingRepository = listingRepository
        self.itemsPerPage = itemsPerPage
    }
}


// MARK: - ListingListRequester

extension DiscoverListingListRequester: ListingListRequester {

    var isFirstPage: Bool {
        return offset == 0
    }
    
    func canRetrieve() -> Bool {
        return true
    }

    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?) {
        offset = 0
        listingsRetrieval(completion)
    }

    func retrieveNextPage(_ completion: ListingsRequesterCompletion?) {
        listingsRetrieval(completion)
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        return resultCount == 0
    }
    func updateInitialOffset(_ newOffset: Int) {}

    func duplicate() -> ListingListRequester {
        let r = DiscoverListingListRequester(listingId: listingObjectId, itemsPerPage: itemsPerPage)
        r.offset = offset
        return r
    }
    func distanceFromListingCoordinates(_ listingCoords: LGLocationCoordinates2D) -> Double? {
        // method needed for protocol implementation, not used for discover
        return nil
    }
    var countryCode: String? {
        // method needed for protocol implementation, not used for discover
        return nil
    }

    func isEqual(toRequester requester: ListingListRequester) -> Bool {
        guard let requester = requester as? DiscoverListingListRequester else { return false }
        return listingObjectId == requester.listingObjectId
    }
}


// MARK: - DiscoverListingListRequester

fileprivate extension DiscoverListingListRequester {

    var retrieveListingParams: RetrieveListingParams {
        var params = RetrieveListingParams()
        params.offset = offset
        params.numListings = itemsPerPage
        return params
    }

    func listingsRetrieval(_ completion: ListingsRequesterCompletion?) {
        listingRepository.indexDiscover(listingId: listingObjectId, params: retrieveListingParams) { [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(ListingsRequesterResult(listingsResult: result, context: nil))
        }
    }
}
