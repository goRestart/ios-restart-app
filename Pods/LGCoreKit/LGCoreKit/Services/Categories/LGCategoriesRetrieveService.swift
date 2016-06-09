//
//  LGCategoriesRetrieveService.swift
//  LGCoreKit
//
//  Created by AHL on 28/6/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

final public class LGCategoriesRetrieveService: CategoriesRetrieveService {

    // MARK: - Lifecycle

    public init() {
    }

    // MARK: - CategoriesRetrieveService

    public func retrieveCategoriesWithCompletion(completion: CategoriesRetrieveServiceCompletion?) {
        completion?(CategoriesRetrieveServiceResult(value: ProductCategory.allValues()))
    }
}
