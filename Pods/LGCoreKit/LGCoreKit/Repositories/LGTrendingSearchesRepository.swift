//
//  LGTrendingSearchesRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


final class LGTrendingSearchesRepository: TrendingSearchesRepository {

    private var searchesByCountry: [String : [String]] = [:]
    private let dataSource: TrendingSearchesDataSource

    // MARK: - Lifecycle

    init(dataSource: TrendingSearchesDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Public methods

    func index(countryCode: String, completion: TrendingSearchesCompletion?) {

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