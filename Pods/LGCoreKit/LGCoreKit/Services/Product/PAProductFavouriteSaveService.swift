//
//  PAProductFavouriteSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAProductFavouriteSaveService: ProductFavouriteSaveService {
    
    // MARK: - Lifecycle
    
    public init() {
    }
    
    // MARK: - ProductFavouriteSaveService
    
    public func saveFavouriteProduct(product: Product, user: User, result: ProductFavouriteSaveServiceResult?) {
        if let productId = product.objectId, let userId = user.objectId {
            let productFavourite = PAProductFavourite()
            productFavourite.user = PFUser(withoutDataWithObjectId: userId)
            productFavourite.product = PAProduct(withoutDataWithObjectId: productId)
            productFavourite.saveInBackgroundWithBlock { [weak self] (success: Bool, error: NSError?) -> Void in
                // Success
                if success {
                    result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.success(productFavourite))
                }
                // Error
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.failure(.Network))
                    default:
                        result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.failure(.Internal))
                    }
                }
                else {
                    result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.failure(.Internal))
                }
            }
        }
        else {
            result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.failure(.Internal))
        }
    }
}