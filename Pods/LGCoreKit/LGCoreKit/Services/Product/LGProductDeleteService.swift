//
//  LGProductDeleteService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result
import Argo

final public class LGProductDeleteService: ProductDeleteService {
    
    public func deleteProduct(product: Product, sessionToken: String, completion: ProductDeleteServiceCompletion?) {
        
        guard let productId = product.objectId else {
            completion?(ProductDeleteServiceResult(error: .Internal))
            return
        }
        
        let request = ProductRouter.Delete(productId: productId)
        
        ApiClient.request(request, decoder: {$0}) { (result: Result<AnyObject, ApiError>) -> () in
            if let error = result.error {
                completion?(ProductDeleteServiceResult(error: ProductDeleteServiceError(apiError: error)))
            } else {
                var deletedProduct = LGProduct(product: product)
                deletedProduct.status = .Deleted
                completion?(ProductDeleteServiceResult(value: deletedProduct))
            }
        }
    }
}