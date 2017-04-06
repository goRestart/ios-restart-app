//
//  SearchesRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias TrendingSearchesResult = Result<[String], RepositoryError>
public typealias TrendingSearchesCompletion = (TrendingSearchesResult) -> Void

public protocol TrendingSearchesRepository {
    func index(_ countryCode: String, completion: TrendingSearchesCompletion?)
}
