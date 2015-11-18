//
//  UserProductsRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 09/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Result

public protocol UserProductsRetrieveService {
    
    /**
        Retrieves the products with the given parameters.
    
        - parameter params: The product retrieval parameters.
        - parameter completion: The completion closure.
    */
    func retrieveUserProductsWithParams(params: RetrieveProductsParams, completion: ProductsRetrieveServiceCompletion?)
}