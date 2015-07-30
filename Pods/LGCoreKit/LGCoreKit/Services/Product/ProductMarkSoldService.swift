//
//  ProductMarkSoldService.swift
//  LGCoreKit
//
//  Created by AHL on 29/7/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductMarkSoldServiceError: Printable {
    case Network
    case Internal
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Internal:
            return "Internal"
        }
    }
}

public typealias ProductMarkSoldServiceResult = (Result<Product, ProductMarkSoldServiceError>) -> Void

public protocol ProductMarkSoldService {
    
    /**
        Marks a product as sold.
    
        :param: product The product.
        :param: result The completion closure.
    */
    func markAsSoldProduct(product: Product, result: ProductMarkSoldServiceResult?)
}
