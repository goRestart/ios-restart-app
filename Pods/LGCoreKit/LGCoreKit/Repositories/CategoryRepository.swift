//
//  CategoryRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 27/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias CategoriesResult = Result<[ProductCategory], RepositoryError>
public typealias CategoriesCompletion = CategoriesResult -> Void

public final class CategoryRepository {

    public func index(filterVisible filter: Bool, completion: CategoriesCompletion?) {
        if filter {
            completion?(CategoriesResult(value: ProductCategory.visibleValues()))
        } else {
            completion?(CategoriesResult(value: ProductCategory.allValues()))
        }
    }
}
