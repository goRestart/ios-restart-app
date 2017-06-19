
//
//  LGCategoryRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


final class LGCategoryRepository: CategoryRepository {

    func index(filterVisible filtered: Bool, completion: CategoriesCompletion?) {
        completion?(CategoriesResult(value: ListingCategory.visibleValues(filtered: filtered)))
    }
}
