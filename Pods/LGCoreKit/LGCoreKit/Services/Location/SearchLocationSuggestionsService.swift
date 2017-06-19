//
//  SearchLocationSuggestionsService.swift
//  LGCoreKit
//
//  Created by Dídac on 31/05/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Result

public enum SearchLocationSuggestionsServiceError: Error {
    case network
    case internalError
    case notFound
}

public typealias SearchLocationSuggestionsServiceResult = Result<[Place], SearchLocationSuggestionsServiceError>
public typealias SearchLocationSuggestionsServiceCompletion = (SearchLocationSuggestionsServiceResult) -> Void

public protocol SearchLocationSuggestionsService {
    func retrieveAddressForLocation(_ searchText: String, completion: SearchLocationSuggestionsServiceCompletion?)
}
