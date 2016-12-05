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

public protocol CategoryRepository {
    func index(filterVisible filter: Bool, completion: CategoriesCompletion?)
}
