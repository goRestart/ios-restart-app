//
//  ProductMarkUnsoldService.swift
//  LGCoreKit
//
//  Created by Dídac on 02/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductMarkUnsoldServiceError: ErrorType, CustomStringConvertible {
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

public typealias ProductMarkUnsoldServiceResult = Result<Product, ProductMarkUnsoldServiceError>
public typealias ProductMarkUnsoldServiceCompletion = ProductMarkUnsoldServiceResult -> Void

public protocol ProductMarkUnsoldService {
    
    /**
    Marks a product as unsold.
    
    - parameter product: The product.
    - parameter completion: The completion closure.
    */
    func markAsUnsoldProduct(product: Product, sessionToken: String, completion: ProductMarkUnsoldServiceCompletion?)
}
