//
//  MockSuggestedLocationsRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 27/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//


final class MockSuggestedLocationsRepository: SuggestedLocationsRepository {

    public var meetingSuggestedLocationsResult: MeetingSuggestedLocationsRepositoryResult!

    public func retrieveSuggestedLocationsForListing(listingId: String,
                                                     completion: MeetingSuggestedLocationsRepositoryCompletion?) {
        delay(result: meetingSuggestedLocationsResult, completion: completion)
    }
}
