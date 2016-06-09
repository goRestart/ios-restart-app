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

    private var searchesByCountry: [String : [String]] = [:]
    private let dataSource: TrendingSearchesDataSource

    // MARK: - Lifecycle

    init(dataSource: TrendingSearchesDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Public methods

    public func index(countryCode: String, completion: TrendingSearchesCompletion?) {

        if let cached = searchesByCountry[countryCode] {
            completion?(TrendingSearchesResult(value: cached))
            return
        }

        dataSource.index(countryCode) { [weak self] result in
            if let searches = result.value {
                self?.searchesByCountry[countryCode] = searches
            }
            handleApiResult(result, completion: completion)
        }
    }
}
