//
//  ProductsFavouriteRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 02/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductsFavouriteRetrieveServiceError: ErrorType, CustomStringConvertible {
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

public typealias ProductsFavouriteRetrieveServiceResult = Result<ProductsFavouriteResponse, ProductsFavouriteRetrieveServiceError>
public typealias ProductsFavouriteRetrieveServiceCompletion = ProductsFavouriteRetrieveServiceResult -> Void

public protocol ProductsFavouriteRetrieveService {
    
    /**
    Retrieves the products with the given parameters.
    
    - parameter params: The product retrieval parameters.
    - parameter completion: The completion closure.
    */
    func retrieveFavouriteProducts(user: User, completion: ProductsFavouriteRetrieveServiceCompletion?)
}
