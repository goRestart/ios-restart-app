//
//  MockSearchLocationSuggestionsService.swift
//  LGCoreKit
//
//  Created by Dídac on 31/05/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//


open class MockSearchLocationSuggestionsService: MockBaseService<[Place], SearchLocationSuggestionsServiceError>, SearchLocationSuggestionsService {

    // MARK: - Lifecycle

    public required init(value: [Place]) {
        super.init(value: value)
    }

    public required init(error: SearchLocationSuggestionsServiceError) {
        super.init(error: error)
    }

    // MARK: - SearchLocationSuggestionsService

    public func retrieveAddressForLocation(_ searchText: String, completion: SearchLocationSuggestionsServiceCompletion?) {
        delay(result: result, completion: completion)
    }
}
