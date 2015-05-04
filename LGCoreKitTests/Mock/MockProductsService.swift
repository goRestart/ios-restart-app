//
//  MockProductsService.swift
//  LGCoreKit
//
//  Created by AHL on 2/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import LGCoreKit

class MockProductsService: ProductsService {
    var products: [LGPartialProduct]?
    var lastPage: Bool?
    var error: NSError?
    
    func retrieveProductsWithParams(params: RetrieveProductsParams, completion: RetrieveProductsCompletion) {
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            completion(products: self.products, lastPage: self.lastPage, error: self.error)
        }
    }
}
