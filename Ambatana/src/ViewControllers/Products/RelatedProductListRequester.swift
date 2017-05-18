//
//  RelatedProductListRequester.swift
//  LetGo
//
//  Created by Dídac on 21/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class RelatedProductListRequester: ProductListRequester {
    let itemsPerPage: Int
    private let productObjectId: String
    private let listingRepository: ListingRepository
    private var offset: Int = 0

    private var retrieveProductParams: RetrieveListingParams {
        var params = RetrieveListingParams()
        params.numProducts = itemsPerPage
        params.offset = offset
        return params
    }

    convenience init(productId: String, itemsPerPage: Int) {
        self.init(productId: productId, itemsPerPage: itemsPerPage, listingRepository: Core.listingRepository)
    }

    init(productId: String, itemsPerPage: Int, listingRepository: ListingRepository) {
        self.productObjectId = productId
        self.listingRepository = listingRepository
        self.itemsPerPage = itemsPerPage
    }

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

    func productsRetrieval(_ completion: ListingsRequesterCompletion?) {
        listingRepository.indexRelated(listingId: productObjectId, params: retrieveProductParams) {
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

    func duplicate() -> ProductListRequester {
        let r = RelatedProductListRequester(productId: productObjectId, itemsPerPage: itemsPerPage)
        r.offset = offset
        return r
    }
    func distanceFromProductCoordinates(_ productCoords: LGLocationCoordinates2D) -> Double? {
        return nil
    }
    var countryCode: String? {
        return nil
    }
}
