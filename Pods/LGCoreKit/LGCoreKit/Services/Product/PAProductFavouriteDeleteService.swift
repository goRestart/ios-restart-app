//
//  PAProductFavouriteDeleteService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAProductFavouriteDeleteService: ProductFavouriteDeleteService {
    
    // MARK: - Lifecycle
    
    public init() {
    }
    
    // MARK: - ProductFavouriteDeleteService
    
    public func deleteProductFavourite(productFavourite: ProductFavourite, result: ProductFavouriteDeleteServiceResult?) {
        // Parse
        if let parseProductFavourite = productFavourite as? PAProductFavourite {
            parseProductFavourite.deleteInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                
                // Success
                if success {
                    result?(Result<Nil, ProductFavouriteDeleteServiceError>.success(Nil()))
                }
                // Error
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        result?(Result<Nil, ProductFavouriteDeleteServiceError>.failure(.Network))
                    default:
                        result?(Result<Nil, ProductFavouriteDeleteServiceError>.failure(.Internal))
                    }
                }
                else {
                    result?(Result<Nil, ProductFavouriteDeleteServiceError>.failure(.Internal))
                }
            }
        }
        else {
            result?(Result<Nil, ProductFavouriteDeleteServiceError>.failure(.Internal))
        }
    }
}