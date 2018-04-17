//
//  SuggestedLocationsApiDataSource.swift
//  LGCoreKit
//
//  Created by Dídac on 27/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

import Result
import CoreLocation

final class SuggestedLocationsApiDataSource: SuggestedLocationsDataSource {

    private var apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // MARK: - SuggestedLocationsDataSource
    
    func retrieveSuggestedLocationsForListing(listingId: String,
                                              completion: MeetingSuggestedLocationsDataSourceCompletion?) {
        let request = SuggestedLocationsRouter.retrieveSuggestedLocations(listingId: listingId)
        apiClient.request(request, decoder: SuggestedLocationsApiDataSource.decoderArray, completion: completion)
    }


    // MARK: Private methods

    private static func decoderArray(_ object: Any) -> [SuggestedLocation]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let suggestedLocations = try JSONDecoder().decode(FailableDecodableArray<LGSuggestedLocation>.self, from: data)
            return suggestedLocations.validElements
        } catch {
            logMessage(.debug, type: .parsing, message: "could not parse SuggestedLocation \(object)")
        }
        return nil
    }
}
