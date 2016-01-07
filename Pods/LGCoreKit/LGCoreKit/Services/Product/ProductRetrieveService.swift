//
//  ProductRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 07/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductRetrieveServiceError: ErrorType, CustomStringConvertible {
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
    
    init(apiError: ApiError) {
        switch apiError {
        case .Internal, .Unauthorized, .NotFound, .AlreadyExists, .Scammer, .InternalServerError:
            self = .Internal
        case .Network:
            self = .Network
        }
    }
    
}

public typealias ProductRetrieveServiceResult = Result<Product, ProductRetrieveServiceError>
public typealias ProductRetrieveServiceCompletion = ProductRetrieveServiceResult -> Void

public protocol ProductRetrieveService {
    
    /**
        Retrieves the product with the given parameters.
    
        - parameter productId: The product id.
        - parameter completion: The completion closure.
    */
    func retrieveProductWithId(productId: String, completion: ProductRetrieveServiceCompletion?)
}
