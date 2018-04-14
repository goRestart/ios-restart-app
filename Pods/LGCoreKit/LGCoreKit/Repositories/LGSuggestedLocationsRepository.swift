//
//  LGSuggestedLocationsRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 27/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result

final public class LGSuggestedLocationsRepository: SuggestedLocationsRepository {

    let suggestedLocationsApiDataSource: SuggestedLocationsDataSource


    // MARK: - Lifecycle

    public init(dataSource: SuggestedLocationsDataSource) {
        self.suggestedLocationsApiDataSource = dataSource
    }

    public func retrieveSuggestedLocationsForListing(listingId: String,
                                                     completion: MeetingSuggestedLocationsRepositoryCompletion?) {
        suggestedLocationsApiDataSource.retrieveSuggestedLocationsForListing(listingId: listingId) { result in
            handleApiResult(result, completion: completion)
        }
    }
}
