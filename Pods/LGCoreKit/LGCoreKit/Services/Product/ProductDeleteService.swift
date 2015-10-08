//
//  ProductDeleteService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductDeleteServiceError {
    case Network
    case Internal
}

public typealias ProductDeleteServiceResult = (Result<Nil, ProductDeleteServiceError>) -> Void

public protocol ProductDeleteService {
    
    /**
        Deletes the product.
    
        :param: productId the product id.
        :param: sessionToken the user session token.
        :param: result The closure containing the result.
    */
    func deleteProductWithId(productId: String, sessionToken: String, result: ProductDeleteServiceResult?)
}
