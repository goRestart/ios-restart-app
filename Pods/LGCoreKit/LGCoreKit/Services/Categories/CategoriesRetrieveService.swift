//
//  CategoriesRetrieveService.swift
//  LGCoreKit
//
//  Created by AHL on 28/6/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum CategoriesRetrieveServiceServiceError: ErrorType {
    case Network
    case Internal
}

public typealias CategoriesRetrieveServiceResult = Result<[ProductCategory], CategoriesRetrieveServiceServiceError>
public typealias CategoriesRetrieveServiceCompletion = CategoriesRetrieveServiceResult -> Void

public protocol CategoriesRetrieveService {
    
    /**
        Retrieves all product categories.
    
        - parameter completion: The completion closure.
    */
    func retrieveCategoriesWithCompletion(completion: CategoriesRetrieveServiceCompletion?)
}