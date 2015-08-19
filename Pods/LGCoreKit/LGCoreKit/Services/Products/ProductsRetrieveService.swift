//
//  ProductsRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductsRetrieveServiceError: Printable {
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

public typealias ProductsRetrieveServiceResult = (Result<ProductsResponse, ProductsRetrieveServiceError>) -> Void

public protocol ProductsRetrieveService {
    
    /**
        Retrieves the products with the given parameters.
    
        :param: params The product retrieval parameters.
        :param: completion The completion closure.
    */
    func retrieveProductsWithParams(params: RetrieveProductsParams, result: ProductsRetrieveServiceResult?)
}
