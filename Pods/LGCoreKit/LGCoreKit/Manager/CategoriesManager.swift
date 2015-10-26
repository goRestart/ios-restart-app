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
    
        - parameter completion: The completion closure.
    */
    public func retrieveCategoriesWithCompletion(completion: CategoriesRetrieveServiceCompletion?) {
        // If not cached then retrieve
        if categories.isEmpty {
            let myCompletion: CategoriesRetrieveServiceCompletion = { (theResult: CategoriesRetrieveServiceResult) in
                if let actualCategories = theResult.value {
                    self.categories = actualCategories
                }
                completion?(theResult)
            }
            categoriesRetrieveService.retrieveCategoriesWithCompletion(myCompletion)
        }
        // Otherwise, return the cached categories
        else {
            completion?(CategoriesRetrieveServiceResult(value: categories))
        }
        
    }
}
