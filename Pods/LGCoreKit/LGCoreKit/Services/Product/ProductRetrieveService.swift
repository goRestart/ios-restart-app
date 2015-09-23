//
//  ProductRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 07/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductRetrieveServiceError: Printable {
    case Network
    case Internal
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Internal:
            return "Internal"
        }
    }
}

public typealias ProductRetrieveServiceResult = (Result<Product, ProductRetrieveServiceError>) -> Void

public protocol ProductRetrieveService {
    
    /**
    Retrieves the product with the given parameters.
    
    :param: productId The product id.
    :param: result The completion closure.
    */
    func retrieveProductWithId(productId: String, result: ProductRetrieveServiceResult?)
}
