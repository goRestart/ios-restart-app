//
//  PAProductFavouriteRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAProductFavouriteRetrieveService: ProductFavouriteRetrieveService {
    
    // MARK: - Lifecycle
    
    public init() {
    }
    
    // MARK: - ProductFavouriteRetrieveService
    
    public func retrieveProductFavourite(product: Product, user: User, result: ProductFavouriteRetrieveServiceResult?) {
        if let productId = product.objectId, let userId = user.objectId {
            
            let theProduct = PAProduct(withoutDataWithObjectId: productId)
            let theUser = PFUser(withoutDataWithObjectId: userId)
            
            let query = PFQuery(className: PAProductFavourite.parseClassName())
            query.whereKey(PAProductFavourite.FieldKey.Product.rawValue, equalTo: theProduct)
            query.whereKey(PAProductFavourite.FieldKey.User.rawValue, equalTo: theUser)
            query.limit = 1
            query.findObjectsInBackgroundWithBlock { [weak self] (results: [AnyObject]?, error: NSError?) -> Void in
                if let actualResults = results as? [PAProductFavourite] {
                    // Success
                    if let productFavourite = actualResults.first {
                        result?(Result<ProductFavourite, ProductFavouriteRetrieveServiceError>.success(productFavourite))
                    }
                    // Does not exist error
                    else {
                        result?(Result<ProductFavourite, ProductFavouriteRetrieveServiceError>.failure(.DoesNotExist))
                    }
                }
                // Error
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        result?(Result<ProductFavourite, ProductFavouriteRetrieveServiceError>.failure(.Network))
                    default:
                        result?(Result<ProductFavourite, ProductFavouriteRetrieveServiceError>.failure(.Internal))
                    }
                }
                else {
                    result?(Result<ProductFavourite, ProductFavouriteRetrieveServiceError>.failure(.Internal))
                }
            }
        }
        else {
            result?(Result<ProductFavourite, ProductFavouriteRetrieveServiceError>.failure(.Internal))
        }
    }
}