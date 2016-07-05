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
        // TODO: 🎪 Implement
    }
    
    func retrieveNextPage(completion: ProductsCompletion?) {
        // TODO: 🎪 Implement
    }

    func productsRetrieval(offset offset: Int, completion: ProductsCompletion?) {
        // We need to substract 1 to the offset because every RelatedProductList is always initialized with one product
        // The product that will be use as seed to get the related ones. That product shouldn't be counted in the offset
        productRepository.index(productId: productObjectId, params: RetrieveProductsParams(), pageOffset: offset-1,
                                completion: completion)
    }

    func isLastPage(resultCount: Int) -> Bool {
        return resultCount == 0
    }
}
