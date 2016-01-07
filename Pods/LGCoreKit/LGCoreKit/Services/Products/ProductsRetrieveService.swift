//
//  ProductsRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductsRetrieveServiceError: ErrorType, CustomStringConvertible {
    case Network
    case Internal
    case Forbidden

    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Internal:
            return "Internal"
        case .Forbidden:
            return "Forbidden"
        }
    }

    init(apiError: ApiError) {
        switch apiError {
        case .Scammer:
            self = .Forbidden
        case .Internal, .Unauthorized, .NotFound, .AlreadyExists, .InternalServerError:
            self = .Internal
        case .Network:
            self = .Network
        }
    }
}

public typealias ProductsRetrieveServiceResult = Result<ProductsResponse, ProductsRetrieveServiceError>
public typealias ProductsRetrieveServiceCompletion = ProductsRetrieveServiceResult -> Void

public protocol ProductsRetrieveService {

    /**
        Retrieves the products with the given parameters.

        - parameter params: The product retrieval parameters.
        - parameter completion: The completion closure.
    */
    func retrieveProductsWithParams(params: RetrieveProductsParams, completion: ProductsRetrieveServiceCompletion?)
}
