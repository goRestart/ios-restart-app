//
//  ProductSaveService.swift
//  LGCoreKit
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductSaveServiceError {
    case Network
    case Internal
    case NoImages
    case NoTitle
    case NoPrice
    case NoDescription
    case LongDescription
    case NoCategory
}

public typealias ProductSaveServiceResult = (Result<Product, ProductSaveServiceError>) -> Void

public protocol ProductSaveService {
    
    /**
        Saves the product.
    
        :param: product the product
        :param: user the user
        :param: result The closure containing the result.
    */
    
    func saveProduct(product: Product, forUser user: User, result: ProductSaveServiceResult?)
}