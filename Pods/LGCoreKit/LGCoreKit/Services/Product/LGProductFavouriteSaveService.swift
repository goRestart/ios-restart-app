//
//  LGProductFavouriteSaveService.swift
//  LGCoreKit
//
//  Created by Dídac on 03/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

final public class LGProductFavouriteSaveService: ProductFavouriteSaveService {
    
    public func saveFavouriteProduct(product: Product, user: User, sessionToken: String, completion: ProductFavouriteSaveServiceCompletion?) {
        
        guard let userId = user.objectId else {
            completion?(ProductFavouriteSaveServiceResult(error: .Internal))
            return
        }
        guard let productId = product.objectId else {
            completion?(ProductFavouriteSaveServiceResult(error: .Internal))
            return
        }

        let request = ProductRouter.SaveFavorite(userId: userId, productId: productId)
        ApiClient.request(request, decoder: {$0}) { (result: Result<AnyObject, ApiError>) -> () in
            if let _ = result.value {
                let productFavourite = LGProductFavourite(objectId: nil, product: product, user: user)
                completion?(ProductFavouriteSaveServiceResult(value: productFavourite))
            } else if let error = result.error {
                let favError = ProductFavouriteSaveServiceError(apiError: error)
                completion?(ProductFavouriteSaveServiceResult(error: favError))
            }
        }
    }
}
