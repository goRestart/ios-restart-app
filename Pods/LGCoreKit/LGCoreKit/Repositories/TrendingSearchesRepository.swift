//
//  SearchesRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias TrendingSearchesResult = Result<[String], RepositoryError>
public typealias TrendingSearchesCompletion = TrendingSearchesResult -> Void

public final class TrendingSearchesRepository {

    let dataSource: TrendingSearchesDataSource

    // MARK: - Lifecycle

    init(dataSource: TrendingSearchesDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Public methods

    public func index(countryCode: String, completion: TrendingSearchesCompletion?) {
        dataSource.index(countryCode) { result in
            handleApiResult(result, completion: completion)
        }
    }
}

