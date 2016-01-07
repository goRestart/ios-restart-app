//
//  ProductMarkSoldService.swift
//  LGCoreKit
//
//  Created by AHL on 29/7/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductMarkSoldServiceError: ErrorType, CustomStringConvertible {
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

public typealias ProductMarkSoldServiceResult = Result<Product, ProductMarkSoldServiceError>
public typealias ProductMarkSoldServiceCompletion = ProductMarkSoldServiceResult -> Void

public protocol ProductMarkSoldService {
    
    /**
        Marks a product as sold.
    
        - parameter product: The product.
        - parameter completion: The completion closure.
    */
    func markAsSoldProduct(product: Product, sessionToken: String, completion: ProductMarkSoldServiceCompletion?)
}
