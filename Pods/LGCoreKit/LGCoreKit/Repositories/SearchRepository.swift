//
//  SuggestedSearchesRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias TrendingSearchesResult = Result<[String], RepositoryError>
public typealias SuggestiveSearchesResult = Result<[SuggestiveSearch], RepositoryError>

public typealias TrendingSearchesCompletion = (TrendingSearchesResult) -> Void
public typealias SuggestiveSearchesCompletion = (SuggestiveSearchesResult) -> Void

public protocol SearchRepository {
    func index(countryCode: String,
               completion: TrendingSearchesCompletion?)
    func retrieveSuggestiveSearches(language: String,
                                    limit: Int,
                                    term: String,
                                    shouldIncludeCategories: Bool,
                                    completion: SuggestiveSearchesCompletion?)
}
