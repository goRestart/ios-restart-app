//
//  CategoriesManager.swift
//  LGCoreKit
//
//  Created by AHL on 28/6/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public class CategoriesManager {
    
    // iVars
    // > Data
    public private(set) var categories: [ProductCategory]
    
    // > Services
    private var categoriesRetrieveService: CategoriesRetrieveService
    
    // Singleton
    public static let sharedInstance: CategoriesManager = CategoriesManager()
    
    public init() {
        self.categories = []
        self.categoriesRetrieveService = LGCategoriesRetrieveService()
    }
    
    /**
        Retrieves all product categories.
    
        :param: result The closure containing the result.
    */
    public func retrieveCategoriesWithResult(result: CategoriesRetrieveServiceResult?) {
        // If not cached then retrieve
        if categories.isEmpty {
            let myResult: CategoriesRetrieveServiceResult = { (theResult: Result<[ProductCategory], CategoriesRetrieveServiceServiceError>) in
                if let actualCategories = theResult.value {
                    self.categories = actualCategories
                }
                result?(theResult)
            }
            categoriesRetrieveService.retrieveCategoriesWithResult(myResult)
        }
        // Otherwise, return the cached categories
        else {
            result?(Result<[ProductCategory], CategoriesRetrieveServiceServiceError>.success(categories))
        }
        
    }
}
