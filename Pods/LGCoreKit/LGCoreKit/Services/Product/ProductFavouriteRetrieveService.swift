//
//  ProductFavouriteRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import LGCoreKit
import Result

public enum ProductFavouriteRetrieveServiceError: Printable {
    case DoesNotExist
    case Network
    case Internal
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case DoesNotExist:
            return "DoesNotExist"
        case Internal:
            return "Internal"
        }
    }
}

public typealias ProductFavouriteRetrieveServiceResult = (Result<ProductFavourite, ProductFavouriteRetrieveServiceError>) -> Void

public protocol ProductFavouriteRetrieveService {
    
    /**
        Retrieves if a product is favourited by a user.
    
        :param: product the product.
        :param: user the user.
        :param: result The closure containing the result.
    */
    func retrieveProductFavourite(product: Product, user: User, result: ProductFavouriteRetrieveServiceResult?)
}

