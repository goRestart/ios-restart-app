//
//  ProductsFavouriteRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 02/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductsFavouriteRetrieveServiceError: Printable {
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

public typealias ProductsFavouriteRetrieveServiceResult = (Result<ProductsFavouriteResponse, ProductsFavouriteRetrieveServiceError>) -> Void

public protocol ProductsFavouriteRetrieveService {
    
    /**
    Retrieves the products with the given parameters.
    
    :param: params The product retrieval parameters.
    :param: completion The completion closure.
    */
    func retrieveFavouriteProducts(user: User, result: ProductsFavouriteRetrieveServiceResult?)
}
