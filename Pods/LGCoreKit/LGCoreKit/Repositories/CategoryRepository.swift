//
//  CategoryRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 27/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias TaxonomiesResult = Result<[Taxonomy], RepositoryError>
public typealias TaxonomiesCompletion = (TaxonomiesResult) -> Void

public typealias CategoriesResult = Result<[ListingCategory], RepositoryError>
public typealias CategoriesCompletion = (CategoriesResult) -> Void

public protocol CategoryRepository {
    func index(filterVisible filtered: Bool, completion: CategoriesCompletion?)
    func indexTaxonomies(withCompletion completion: TaxonomiesCompletion?)
    func loadFirstRunCacheIfNeeded(jsonURL: URL)
    func refreshTaxonomiesCache()
}
