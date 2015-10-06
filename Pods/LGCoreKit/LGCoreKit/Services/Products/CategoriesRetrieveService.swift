//
//  CategoriesRetrieveService.swift
//  LGCoreKit
//
//  Created by AHL on 28/6/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum CategoriesRetrieveServiceServiceError {
    case Network
    case Internal
}

public typealias CategoriesRetrieveServiceResult = (Result<[ProductCategory], CategoriesRetrieveServiceServiceError>) -> Void

public protocol CategoriesRetrieveService {
    
    /**
        Retrieves all product categories.
    
        :param: result The closure containing the result.
    */
    func retrieveCategoriesWithResult(result: CategoriesRetrieveServiceResult?)
}