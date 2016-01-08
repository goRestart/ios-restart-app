//
//  ProductSaveService.swift
//  LGCoreKit
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductSaveServiceError: String, ErrorType {
    case Network = "network"
    case Internal = "internal"
    case NoImages = "no images present"
    case NoTitle  = "no title"
    case NoPrice = "invalid price"
    case NoDescription = "no description"
    case LongDescription = "description too long"
    case NoCategory = "no category selected"
    case Forbidden = "forbidden"


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

public typealias ProductSaveServiceResult = Result<Product, ProductSaveServiceError>
public typealias ProductSaveServiceCompletion = ProductSaveServiceResult -> Void

public protocol ProductSaveService {

    /**
        Saves the product.

        - parameter product: the product
        - parameter user: the user
        - parameter completion: The completion closure.
    */
    func saveProduct(product: Product, forUser user: User, sessionToken: String, completion: ProductSaveServiceCompletion?)
}
