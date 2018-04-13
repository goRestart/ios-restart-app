//
//  SuggestedLocationsRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 27/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

import Result
import CoreLocation

public typealias MeetingSuggestedLocationsRepositoryResult = Result<[SuggestedLocation], RepositoryError>
public typealias MeetingSuggestedLocationsRepositoryCompletion = (MeetingSuggestedLocationsRepositoryResult) -> Void

public protocol SuggestedLocationsRepository {
    func retrieveSuggestedLocationsForListing(listingId: String, completion: MeetingSuggestedLocationsRepositoryCompletion?)
}
