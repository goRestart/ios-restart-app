//
//  ProductFavouriteDeleteService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductFavouriteDeleteServiceError: ErrorType, CustomStringConvertible {
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
        case .Network:
            self = .Network
        case .Internal, .Unauthorized, .NotFound, .AlreadyExists, .Scammer, .InternalServerError:
            self = .Internal
        }
    }
}

public typealias ProductFavouriteDeleteServiceResult = Result<Nil, ProductFavouriteDeleteServiceError>
public typealias ProductFavouriteDeleteServiceCompletion = ProductFavouriteDeleteServiceResult -> Void

public protocol ProductFavouriteDeleteService {

    /**
        Deletes a product from favourites for the given user.

        - parameter productFavourite: the favourite product.
        - parameter completion: The completion closure.
    */
    func deleteProductFavourite(productFavourite: ProductFavourite, sessionToken: String, completion: ProductFavouriteDeleteServiceCompletion?)
}
