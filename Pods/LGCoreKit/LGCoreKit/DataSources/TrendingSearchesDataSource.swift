//
//  SearchesDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

typealias TrendingSearchesDataSourceResult = Result<[String], ApiError>
typealias TrendingSearchesDataSourceCompletion = (TrendingSearchesDataSourceResult) -> Void

protocol TrendingSearchesDataSource {
    func index(_ countryCode: String, completion: TrendingSearchesDataSourceCompletion?)
}
