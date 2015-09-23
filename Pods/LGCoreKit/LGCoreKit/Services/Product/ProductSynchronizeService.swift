//
//  ProductSynchronizeService.swift
//  LGCoreKit
//
//  Created by AHL on 29/7/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public typealias ProductSynchronizeServiceResult = () -> Void

public protocol ProductSynchronizeService {
    
    /**
        Synchronizes a product.
    
        :param: productId The product identifier.
        :param: result The completion closure.
    */
    func synchronizeProductWithId(productId: String, result: ProductSynchronizeServiceResult?)
    
    /**
        Synchronously, synchronizes a product.
    
        :param: productId The product identifier.
        :param: result The completion closure.
    */
    func synchSynchronizeProductWithId(productId: String, result: ProductSynchronizeServiceResult?)
}

