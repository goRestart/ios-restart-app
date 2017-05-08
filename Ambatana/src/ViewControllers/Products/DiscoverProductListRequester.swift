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

    func retrieveFirstPage(_ completion: ListingsCompletion?) {
        offset = 0
        productsRetrieval(completion)
    }

    func retrieveNextPage(_ completion: ListingsCompletion?) {
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
}


// MARK: - DiscoverProductListRequester

fileprivate extension DiscoverProductListRequester {

    var retrieveProductsParams: RetrieveListingParams {
        var params = RetrieveListingParams()
        params.offset = offset
        params.numProducts = itemsPerPage
        return params
    }

    func productsRetrieval(_ completion: ListingsCompletion?) {
        listingRepository.indexDiscover(listingId: productObjectId, params: retrieveProductsParams) { [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(result)
        }
    }
}
