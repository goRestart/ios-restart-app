//
//  ProductReportRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import LGCoreKit
import Result

public enum ProductReportRetrieveServiceError: Printable {
    case Network
    case DoesNotExist
    case Internal
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case DoesNotExist:
            return "DoesNotExist"
        case Internal:
            return "Internal"
        }
    }
}

public typealias ProductReportRetrieveServiceResult = (Result<ProductReport, ProductReportRetrieveServiceError>) -> Void

public protocol ProductReportRetrieveService {
    
    /**
        Retrieves if a product is reported by a user.
    
        :param: product the product.
        :param: user the reporter user.
        :param: result The closure containing the result.
    */
    func retrieveReportForProduct(product: Product, user: User, result: ProductReportRetrieveServiceResult?)
}
