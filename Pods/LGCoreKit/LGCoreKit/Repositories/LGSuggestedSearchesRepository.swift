//
//  LGSuggestedSearchesRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


final class LGSuggestedSearchesRepository: SuggestedSearchesRepository {

    private var searchesByCountry: [String : [String]] = [:]
    private let dataSource: SuggestedSearchesDataSource

    // MARK: - Lifecycle

    init(dataSource: SuggestedSearchesDataSource) {
        self.dataSource = dataSource
    }

    
    // MARK: - Public methods

    func index(_ countryCode: String, completion: SuggestedSearchesCompletion?) {
        if let cached = searchesByCountry[countryCode] {
            completion?(SuggestedSearchesResult(value: cached))
            return
        }

        dataSource.index(countryCode) { [weak self] result in
            if let searches = result.value {
                self?.searchesByCountry[countryCode] = searches
            }
            handleApiResult(result, completion: completion)
            
            self?.retrieveSuggestiveSearches(countryCode, limit: 20, term: "do") { result in
                print(result)
            }
        }
    }
    
    func retrieveSuggestiveSearches(_ countryCode: String, limit: Int, term: String, completion: SuggestiveSearchesCompletion?) {
        dataSource.retrieveSuggestiveSearches(countryCode, limit: limit, term: term) { [weak self] result in
            //if let searches = result.value {
            //    self?.searchesByCountry[countryCode] = searches
            //}
            handleApiResult(result, completion: completion)
        }
    }
}
