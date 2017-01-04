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
    private let productObjectId: String
    private let productRepository: ProductRepository
    private var offset: Int = 0

    convenience init(productId: String, itemsPerPage: Int) {
        self.init(productId: productId, itemsPerPage: itemsPerPage, productRepository: Core.productRepository)
    }

    init(productId: String, itemsPerPage: Int, productRepository: ProductRepository) {
        self.productObjectId = productId
        self.productRepository = productRepository
        self.itemsPerPage = itemsPerPage
    }
}


// MARK: - ProductListRequester

extension DiscoverProductListRequester: ProductListRequester {
    func canRetrieve() -> Bool {
        return true
    }

    func retrieveFirstPage(_ completion: ProductsCompletion?) {
        offset = 0
        productsRetrieval(completion)
    }

    func retrieveNextPage(_ completion: ProductsCompletion?) {
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

private extension DiscoverProductListRequester {

    var retrieveProductsParams: RetrieveProductsParams {
        var params = RetrieveProductsParams()
        params.offset = offset
        params.numProducts = itemsPerPage
        return params
    }

    func productsRetrieval(_ completion: ProductsCompletion?) {
        productRepository.indexDiscover(productId: productObjectId, params: retrieveProductsParams) { [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(result)
        }
    }
}
