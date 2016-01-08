//
//  LGProductMarkSoldService.swift
//  LGCoreKit
//
//  Created by Dídac on 04/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

final public class LGProductMarkSoldService: ProductMarkSoldService {

    public func markAsSoldProduct(product: Product, sessionToken: String, completion: ProductMarkSoldServiceCompletion?) {

        guard let productId = product.objectId else {
            completion?(ProductMarkSoldServiceResult(error: .Internal))
            return
        }

        let params: [String: AnyObject] = ["status": ProductStatus.Sold.rawValue]

        let request = ProductRouter.Patch(productId: productId, params: params)
        ApiClient.request(request, decoder: {$0}) { (result: Result<AnyObject, ApiError>) -> () in
            if let _ = result.value {
                var result = LGProduct(product: product)
                result.status = .Sold
                completion?(ProductMarkSoldServiceResult(value: result))
            } else if let error = result.error {
                let favError = ProductMarkSoldServiceError(apiError: error)
                completion?(ProductMarkSoldServiceResult(error: favError))
            }
        }
    }
}
