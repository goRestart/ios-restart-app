//
//  SuggestedSearchesDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

typealias SuggestedSearchesDataSourceResult = Result<[String], ApiError>
typealias SuggestiveSearchesDataSourceResult = Result<[SuggestiveSearch], ApiError>

typealias SuggestedSearchesDataSourceCompletion = (SuggestedSearchesDataSourceResult) -> Void
typealias SuggestiveSearchesDataSourceCompletion = (SuggestiveSearchesDataSourceResult) -> Void

protocol SuggestedSearchesDataSource {
    func index(_ countryCode: String, completion: SuggestedSearchesDataSourceCompletion?)
    func retrieveSuggestiveSearches(_ countryCode: String, limit: Int, term: String, completion: SuggestiveSearchesDataSourceCompletion?)
}
