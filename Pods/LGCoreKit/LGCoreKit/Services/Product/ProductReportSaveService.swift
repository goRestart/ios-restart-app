//
//  ProductReportSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import LGCoreKit
import Result

public enum ProductReportSaveServiceError: Printable {
    case Network
    case AlreadyExists
    case Internal
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case AlreadyExists:
            return "AlreadyExists"
        case Internal:
            return "Internal"
        }
    }
}

public typealias ProductReportSaveServiceResult = (Result<Nil, ProductReportSaveServiceError>) -> Void

public protocol ProductReportSaveService {
    
    /**
        Reports a product.
    
        :param: product the product.
        :param: user the reporter user.
        :param: result The closure containing the result.
    */
    func saveReportProduct(product: Product, user: User, result: ProductReportSaveServiceResult?)
}