//
//  ProductSaveService.swift
//  LGCoreKit
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductSaveServiceError: String {
    case Network = "network"
    case Internal = "internal"
    case NoImages = "no images present"
    case NoTitle  = "no title"
    case NoPrice = "invalid price"
    case NoDescription = "no description"
    case LongDescription = "description too long"
    case NoCategory = "no category selected"
}

public typealias ProductSaveServiceResult = (Result<Product, ProductSaveServiceError>) -> Void

public protocol ProductSaveService {
    
    /**
        Saves the product.
    
        :param: product the product
        :param: user the user
        :param: result The closure containing the result.
    */
    // TODO: Change this user to user_id
    func saveProduct(product: Product, forUser user: User, sessionToken: String, result: ProductSaveServiceResult?)
}