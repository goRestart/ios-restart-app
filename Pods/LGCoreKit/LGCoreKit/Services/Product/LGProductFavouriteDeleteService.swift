//
//  LGProductFavouriteDeleteService.swift
//  LGCoreKit
//
//  Created by Dídac on 03/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

final public class LGProductFavouriteDeleteService: ProductFavouriteDeleteService {
    
    public func deleteProductFavourite(productFavourite: ProductFavourite, sessionToken: String, completion: ProductFavouriteDeleteServiceCompletion?) {
        
        guard let userId = productFavourite.user.objectId else {
            completion?(ProductFavouriteDeleteServiceResult(error: .Internal))
            return
        }
        guard let productId = productFavourite.product.objectId else {
            completion?(ProductFavouriteDeleteServiceResult(error: .Internal))
            return
        }
        
        let request = ProductRouter.DeleteFavorite(userId: userId, productId: productId)
        ApiClient.request(request, decoder: {$0}) { (result: Result<AnyObject, ApiError>) -> () in
            if let _ = result.value {
                completion?(ProductFavouriteDeleteServiceResult(value: Nil()))
            } else if let error = result.error {
                let favError = ProductFavouriteDeleteServiceError(apiError: error)
                completion?(ProductFavouriteDeleteServiceResult(error: favError))
            }
        }
    }
}
