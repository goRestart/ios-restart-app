//
//  SuggestedSearchesRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias SuggestedSearchesResult = Result<[String], RepositoryError>
public typealias SuggestiveSearchesResult = Result<[SuggestiveSearch], RepositoryError>

public typealias SuggestedSearchesCompletion = (SuggestedSearchesResult) -> Void
public typealias SuggestiveSearchesCompletion = (SuggestiveSearchesResult) -> Void

public protocol SuggestedSearchesRepository {
    func index(_ countryCode: String, completion: SuggestedSearchesCompletion?)
    func retrieveSuggestiveSearches(_ countryCode: String, limit: Int, term: String, completion: SuggestiveSearchesCompletion?)
}
