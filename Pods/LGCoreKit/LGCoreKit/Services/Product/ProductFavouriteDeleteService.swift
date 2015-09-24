//
//  ProductFavouriteDeleteService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import LGCoreKit
import Result

public enum ProductFavouriteDeleteServiceError: Printable {
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

public typealias ProductFavouriteDeleteServiceResult = (Result<Nil, ProductFavouriteDeleteServiceError>) -> Void

public protocol ProductFavouriteDeleteService {
    
    /**
        Deletes a product from favourites for the given user.
    
        :param: productFavourite the favourite product.
        :param: result The closure containing the result.
    */
    func deleteProductFavourite(productFavourite: ProductFavourite, sessionToken: String, result: ProductFavouriteDeleteServiceResult?)
}
