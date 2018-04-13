//
//  SuggestedLocationsDataSource.swift
//  LGCoreKit
//
//  Created by Dídac on 27/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation
import Result


public typealias MeetingSuggestedLocationsDataSourceResult = Result<[SuggestedLocation], ApiError>
public typealias MeetingSuggestedLocationsDataSourceCompletion = (MeetingSuggestedLocationsDataSourceResult) -> Void

public protocol SuggestedLocationsDataSource {
    func retrieveSuggestedLocationsForListing(listingId: String,
                                              completion: MeetingSuggestedLocationsDataSourceCompletion?)
}
