//
//  ProductFavouriteSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductFavouriteSaveServiceError: ErrorType, CustomStringConvertible {
    case Network
    case Internal
    case AlreadyExists
    case Forbidden
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Internal:
            return "Internal"
        case .AlreadyExists:
            return "AlreadyExists"
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

public typealias ProductFavouriteSaveServiceResult = Result<ProductFavourite, ProductFavouriteSaveServiceError>
public typealias ProductFavouriteSaveServiceCompletion = ProductFavouriteSaveServiceResult -> Void

public protocol ProductFavouriteSaveService {
    
    /**
        Adds a product to favourites for the given user.
    
        - parameter product: the product.
        - parameter user: the user.
        - parameter completion: The completion closure.
    */
    func saveFavouriteProduct(product: Product, user: User, sessionToken: String, completion: ProductFavouriteSaveServiceCompletion?)
}
