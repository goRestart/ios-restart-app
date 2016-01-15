//
//  LGProductRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 07/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result
import Argo

final public class LGProductRetrieveService: ProductRetrieveService {

    public func retrieveProductWithId(productId: String, completion: ProductRetrieveServiceCompletion?) {
        let request = ProductRouter.Show(productId: productId)
        ApiClient.request(request, decoder: LGProductRetrieveService.decoder) { (result: Result<Product, ApiError>) -> () in
            if let value = result.value {
                completion?(ProductRetrieveServiceResult(value: value))
            } else if let error = result.error {
                completion?(ProductRetrieveServiceResult(error: ProductRetrieveServiceError(apiError: error)))
            }
        }
    }

    static func decoder(object: AnyObject) -> Product? {
        let theProduct : LGProduct? = decode(object)
        return theProduct
    }
}

