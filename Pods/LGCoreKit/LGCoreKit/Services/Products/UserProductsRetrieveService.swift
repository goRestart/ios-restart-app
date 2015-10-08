//
//  UserProductsRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 09/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Result

//public enum UserProductsRetrieveServiceError: Printable {
//    case Network
//    case Internal
//    
//    public var description: String {
//        switch (self) {
//        case Network:
//            return "Network"
//        case Internal:
//            return "Internal"
//        }
//    }
//}


//public typealias UserProductsRetrieveServiceResult = (Result<ProductsResponse, UserProductsRetrieveServiceError>) -> Void

public protocol UserProductsRetrieveService {
    
    /**
    Retrieves the products with the given parameters.
    
    :param: params The product retrieval parameters.
    :param: completion The completion closure.
    */
    func retrieveUserProductsWithParams(params: RetrieveProductsParams, result: ProductsRetrieveServiceResult?)
}