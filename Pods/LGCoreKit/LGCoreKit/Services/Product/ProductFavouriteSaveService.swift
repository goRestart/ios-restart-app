//
//  ProductFavouriteSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import LGCoreKit
import Result

public enum ProductFavouriteSaveServiceError: Printable {
    case Network
    case Internal
    case AlreadyExists
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Internal:
            return "Internal"
        case .AlreadyExists:
            return "AlreadyExists"
        }
    }
}

public typealias ProductFavouriteSaveServiceResult = (Result<ProductFavourite, ProductFavouriteSaveServiceError>) -> Void

public protocol ProductFavouriteSaveService {
    
    /**
        Adds a product to favourites for the given user.
    
        :param: product the product.
        :param: user the user.
        :param: result The closure containing the result.
    */
    func saveFavouriteProduct(product: Product, user: User, sessionToken: String, result: ProductFavouriteSaveServiceResult?)
}
