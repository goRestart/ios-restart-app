//
//  RelatedListingListRequester.swift
//  LetGo
//
//  Created by Dídac on 21/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class RelatedListingListRequester: ListingListRequester {
    let itemsPerPage: Int
    fileprivate let listingObjectId: String
    private let listingRepository: ListingRepository
    private var offset: Int = 0

    private var retrieveListingParams: RetrieveListingParams {
        var params = RetrieveListingParams()
        params.numListings = itemsPerPage
        params.offset = offset
        return params
    }

    convenience init(listingId: String, itemsPerPage: Int) {
        self.init(listingId: listingId, itemsPerPage: itemsPerPage, listingRepository: Core.listingRepository)
    }

    init(listingId: String, itemsPerPage: Int, listingRepository: ListingRepository) {
        self.listingObjectId = listingId
        self.listingRepository = listingRepository
        self.itemsPerPage = itemsPerPage
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

    func listingsRetrieval(_ completion: ListingsRequesterCompletion?) {
        listingRepository.indexRelated(listingId: listingObjectId, params: retrieveListingParams) {
            [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(ListingsRequesterResult(listingsResult: result, context: nil))
        }
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        return resultCount == 0
    }

    func updateInitialOffset(_ newOffset: Int) {}

    func duplicate() -> ListingListRequester {
        let r = RelatedListingListRequester(listingId: listingObjectId, itemsPerPage: itemsPerPage)
        r.offset = offset
        return r
    }
    func distanceFromListingCoordinates(_ listingCoords: LGLocationCoordinates2D) -> Double? {
        // method needed for protocol implementation, not used for related
        return nil
    }
    var countryCode: String? {
        // method needed for protocol implementation, not used for related
        return nil
    }

    func isEqual(toRequester requester: ListingListRequester) -> Bool {
        guard let requester = requester as? RelatedListingListRequester else { return false }
        return listingObjectId == requester.listingObjectId
    }
}

