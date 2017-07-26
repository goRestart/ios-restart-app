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
    func index(_ countryCode: String, completion: TrendingSearchesDataSourceCompletion?)
    func retrieveSuggestiveSearches(_ countryCode: String, limit: Int, term: String, completion: SuggestiveSearchesDataSourceCompletion?)
}
