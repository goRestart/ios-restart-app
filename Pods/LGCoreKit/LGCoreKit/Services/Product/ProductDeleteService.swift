//
//  ProductDeleteService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductDeleteServiceError: ErrorType {
    case Network
    case Internal
}

public typealias ProductDeleteServiceResult = Result<Product, ProductDeleteServiceError>
public typealias ProductDeleteServiceCompletion = ProductDeleteServiceResult -> Void

public protocol ProductDeleteService {
    
    /**
        Deletes the product.
    
        - parameter product: the product to be deleted.
        - parameter sessionToken: the user session token.
        - parameter completion: The completion closure.
    */
    func deleteProduct(product: Product, sessionToken: String, completion: ProductDeleteServiceCompletion?)
}
