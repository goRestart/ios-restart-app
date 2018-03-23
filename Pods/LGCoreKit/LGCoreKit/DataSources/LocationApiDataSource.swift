//
//  LocationApiDataSource.swift
//  LGCoreKit
//
//  Created by Dídac on 09/02/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Result
import CoreLocation

class LocationApiDataSource: LocationDataSource {

    private var apiClient: ApiClient

    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    // MARK: - LocationDataSource

    func retrieveLocationSuggestions(addressString: String,
                                     region: CLCircularRegion?,
                                     completion: SuggestionsLocationDataSourceCompletion?) {

    }

    func retrievePostalAddress(location: LGLocationCoordinates2D,
                               completion: PostalAddressLocationDataSourceCompletion?) {

    }

    func retrieveLocationSuggestionDetails(placeId: String,
                                           completion: SuggestionLocationDetailsDataSourceCompletion?) {

    }

    func retrieveSuggestedLocationsForListing(listingId: String,
                                              completion: MeetingSuggestedLocationsDataSourceCompletion?) {
        let request = SuggestedLocationsRouter.retrieveSuggestedLocations(listingId: listingId)
        apiClient.request(request, decoder: LocationApiDataSource.decoderArray, completion: completion)
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
