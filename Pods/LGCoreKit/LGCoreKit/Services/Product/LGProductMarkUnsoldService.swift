//
//  LGProductMarkUnsoldService.swift
//  LGCoreKit
//
//  Created by Dídac on 02/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result

final public class LGProductMarkUnsoldService: ProductMarkUnsoldService {

    public func markAsUnsoldProduct(product: Product, sessionToken: String, completion: ProductMarkUnsoldServiceCompletion?) {

        guard let productId = product.objectId else {
            completion?(ProductMarkUnsoldServiceResult(error: .Internal))
            return
        }

        let params: [String: AnyObject] = ["status": ProductStatus.Approved.rawValue]

        let request = ProductRouter.Patch(productId: productId, params: params)
        ApiClient.request(request, decoder: {$0}) { (result: Result<AnyObject, ApiError>) -> () in
            if let _ = result.value {
                var result = LGProduct(product: product)
                result.status = .Approved
                completion?(ProductMarkUnsoldServiceResult(value: result))
            } else if let error = result.error {
                let favError = ProductMarkUnsoldServiceError(apiError: error)
                completion?(ProductMarkUnsoldServiceResult(error: favError))
            }
        }
    }
}
