//
//  ProductRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol ProductRetrieveService {
    
    /**
        Retrieves a product with the given parameters.
    
        :param: params The product retrieval parameters.
        :param: completion The completion closure.
    */
    func retrieveProductWithParams(params: RetrieveProductParams, completion: RetrieveProductCompletion?)
}