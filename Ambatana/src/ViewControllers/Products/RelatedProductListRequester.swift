//
//  RelatedProductListRequester.swift
//  LetGo
//
//  Created by Dídac on 21/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class RelatedProductListRequester: ProductListRequester {

    var itemsPerPage: Int = Constants.numProductsPerPage2Columns
    private let productObjectId: String
    private let productRepository: ProductRepository
    private var offset: Int = 0

    private var retrieveProductParams: RetrieveProductsParams {
        var params = RetrieveProductsParams()
        params.numProducts = itemsPerPage
        return params
    }

    convenience init(productId: String) {
        self.init(productId: productId, productRepository: Core.productRepository)
    }

    init(productId: String, productRepository: ProductRepository) {
        self.productObjectId = productId
        self.productRepository = productRepository
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
        productRepository.indexRelated(productId: productObjectId, params: retrieveProductParams, pageOffset: offset) {
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
        let r = RelatedProductListRequester(productId: productObjectId)
        r.offset = offset
        r.itemsPerPage = itemsPerPage
        return r
    }
}
