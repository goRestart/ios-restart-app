//
//  SearchDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

typealias TrendingSearchesDataSourceResult = Result<[String], ApiError>
typealias SuggestiveSearchesDataSourceResult = Result<[SuggestiveSearch], ApiError>

typealias TrendingSearchesDataSourceCompletion = (TrendingSearchesDataSourceResult) -> Void
typealias SuggestiveSearchesDataSourceCompletion = (SuggestiveSearchesDataSourceResult) -> Void

protocol SearchDataSource {
    func index(countryCode: String, completion: TrendingSearchesDataSourceCompletion?)
    func retrieveSuggestiveSearches(language: String,
                                    limit: Int,
                                    term: String,
                                    shouldIncludeCategories: Bool,
                                    completion: SuggestiveSearchesDataSourceCompletion?)
}
