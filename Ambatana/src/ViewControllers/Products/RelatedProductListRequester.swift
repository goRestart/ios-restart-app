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
    private let productRepository: ProductRepository
    private var offset: Int = 0

    private var retrieveProductParams: RetrieveProductsParams {
        var params = RetrieveProductsParams()
        params.numProducts = itemsPerPage
        params.offset = offset
        return params
    }

    convenience init(productId: String, itemsPerPage: Int) {
        self.init(productId: productId, itemsPerPage: itemsPerPage, productRepository: Core.productRepository)
    }

    init(productId: String, itemsPerPage: Int, productRepository: ProductRepository) {
        self.productObjectId = productId
        self.productRepository = productRepository
        self.itemsPerPage = itemsPerPage
    }

    func canRetrieve() -> Bool {
        return true
    }
    
    func retrieveFirstPage(completion: ProductsCompletion?) {
        offset = 0
        productsRetrieval(completion)
    }
    
    func retrieveNextPage(completion: ProductsCompletion?) {
        productsRetrieval(completion)
    }

    func productsRetrieval(completion: ProductsCompletion?) {
        productRepository.indexRelated(productId: productObjectId, params: retrieveProductParams) {
            [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(result)
        }
    }

    func isLastPage(resultCount: Int) -> Bool {
        return resultCount == 0
    }

    func updateInitialOffset(newOffset: Int) {}

    func duplicate() -> ProductListRequester {
        let r = RelatedProductListRequester(productId: productObjectId, itemsPerPage: itemsPerPage)
        r.offset = offset
        return r
    }
}
