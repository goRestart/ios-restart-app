//
//  RelatedProductListRequester.swift
//  LetGo
//
//  Created by Dídac on 21/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class RelatedProductListRequester: ProductListRequester {

    private let productObjectId: String
    private let productRepository: ProductRepository
    private let locationManager: LocationManager
    private var offset: Int = 0

    convenience init(productId: String) {
        self.init(productId: productId, productRepository: Core.productRepository, locationManager: Core.locationManager)
    }

    init(productId: String, productRepository: ProductRepository, locationManager: LocationManager) {
        self.productObjectId = productId
        self.productRepository = productRepository
        self.locationManager = locationManager
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
        productRepository.index(productId: productObjectId, params: RetrieveProductsParams(), pageOffset: offset) { [weak self] result in
            if let value = result.value {
                self?.offset += value.count
            }
            completion?(result)
        }
    }

    func isLastPage(resultCount: Int) -> Bool {
        return resultCount == 0
    }
    
    func duplicate() -> ProductListRequester {
        let r = RelatedProductListRequester(productId: productObjectId)
        r.offset = offset
        return r
    }
}
