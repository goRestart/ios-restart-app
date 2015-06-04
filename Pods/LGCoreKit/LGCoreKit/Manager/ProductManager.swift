//
//  ProductManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 04/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Bolts

public class ProductManager {
    
    private var productRetrieveService: ProductRetrieveService
    
    public init(productRetrieveService: ProductRetrieveService) {
        self.productRetrieveService = productRetrieveService
    }
    
    /**
        Retrieves a product with the given parameters.
    
        :param: params The query parameters to filter the product retrieval.
        :returns: The task that runs the operation. If cannot retrieve next page it returns a task with an internal error.
    */
    public func retrieveProductsWithParams(params: RetrieveProductParams) -> BFTask {
        
        var task = BFTaskCompletionSource()
        productRetrieveService.retrieveProductWithParams(params) { (product: Product?, error: NSError?) -> Void in
            
            // Task
            if let actualError = error {
                task.setError(error)
            }
            else if let actualProduct = product {
                task.setResult(actualProduct)
            }
            else {
                task.setError(NSError(code: LGErrorCode.Internal))
            }
        }
        
        return task.task
    }
}
