//
//  CategoryRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 27/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias CategoriesResult = Result<[ListingCategory], RepositoryError>
public typealias TaxonomiesResult = Result<[Taxonomy], RepositoryError>
public typealias CategoriesCompletion = (CategoriesResult) -> Void
public typealias TaxonomiesCompletion = (TaxonomiesResult) -> Void

public protocol CategoryRepository {
    func index(carsIncluded: Bool, realEstateIncluded: Bool, highlightRealEstate: Bool, completion: CategoriesCompletion?)
    func indexTaxonomies() -> [Taxonomy]
    func loadFirstRunCacheIfNeeded(jsonURL: URL)
    func refreshTaxonomiesCache()
}
