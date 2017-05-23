//
//  DiscoverProductListRequester.swift
//  LetGo
//
//  Created by Albert Hernández López on 14/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class DiscoverProductListRequester {
    let itemsPerPage: Int
    fileprivate let productObjectId: String
    fileprivate let listingRepository: ListingRepository
    fileprivate var offset: Int = 0

    convenience init(productId: String, itemsPerPage: Int) {
        self.init(productId: productId, itemsPerPage: itemsPerPage, listingRepository: Core.listingRepository)
    }

    init(productId: String, itemsPerPage: Int, listingRepository: ListingRepository) {
        self.productObjectId = productId
        self.listingRepository = listingRepository
        self.itemsPerPage = itemsPerPage
    }
}


// MARK: - ProductListRequester

extension DiscoverProductListRequester: ProductListRequester {

    func canRetrieve() -> Bool {
        return true
    }

    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?) {
        offset = 0
        productsRetrieval(completion)
    }

    func retrieveNextPage(_ completion: ListingsRequesterCompletion?) {
        productsRetrieval(completion)
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        return resultCount == 0
    }
    func updateInitialOffset(_ newOffset: Int) {}

    func duplicate() -> ProductListRequester {
        let r = DiscoverProductListRequester(productId: productObjectId, itemsPerPage: itemsPerPage)
        r.offset = offset
        return r
    }
    func distanceFromProductCoordinates(_ productCoords: LGLocationCoordinates2D) -> Double? {
        // method needed for protocol implementation, not used for discover
        return nil
    }
    var countryCode: String? {
        // method needed for protocol implementation, not used for discover
        return nil
    }

    func isEqual(toRequester requester: ProductListRequester) -> Bool {
        guard let requester = requester as? DiscoverProductListRequester else { return false }
        return productObjectId == requester.productObjectId
    }
}


// MARK: - DiscoverProductListRequester

fileprivate extension DiscoverProductListRequester {

    var retrieveProductsParams: RetrieveListingParams {
        var params = RetrieveListingParams()
        params.offset = offset
        params.numProducts = itemsPerPage
        return params
    }

    func productsRetrieval(_ completion: ListingsRequesterCompletion?) {
        listingRepository.indexDiscover(listingId: productObjectId, params: retrieveProductsParams) { [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(ListingsRequesterResult(listingsResult: result, context: nil))
        }
    }
}
