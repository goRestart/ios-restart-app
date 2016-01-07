//
//  LGProductReportSaveService.swift
//  LGCoreKit
//
//  Created by Dídac on 03/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

final public class LGProductReportSaveService: ProductReportSaveService {

    public func saveReportProduct(product: Product, user: User, sessionToken: String, completion: ProductReportSaveServiceCompletion?) {
        guard let userId = user.objectId else {
            completion?(ProductReportSaveServiceResult(error: .Internal))
            return
        }
        guard let productId = product.objectId else {
            completion?(ProductReportSaveServiceResult(error: .Internal))
            return
        }

        let request = ProductRouter.SaveReport(userId: userId, productId: productId)
        ApiClient.request(request, decoder: {$0}) { (result: Result<AnyObject, ApiError>) -> () in
            if let _ = result.value {
                completion?(ProductReportSaveServiceResult(value: Nil()))
            } else if let error = result.error {
                completion?(ProductReportSaveServiceResult(error: ProductReportSaveServiceError(apiError: error)))
            }
        }
    }
}

