//
//  CLSearchLocationSuggestionsService.swift
//  LGCoreKit
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result

public enum SearchLocationSuggestionsServiceError: ErrorType {
    case Network
    case Internal
    case NotFound
}

public typealias SearchLocationSuggestionsServiceResult = Result<[Place], SearchLocationSuggestionsServiceError>
public typealias SearchLocationSuggestionsServiceCompletion = SearchLocationSuggestionsServiceResult -> Void

public class CLSearchLocationSuggestionsService {

    // iVars
    private var geocoder: CLGeocoder

    // MARK: - Lifecycle

    public init() {
        geocoder = CLGeocoder()
    }

    // MARK: - PostalAddressRetrievalService

    public func retrieveAddressForLocation(searchText: String, completion: SearchLocationSuggestionsServiceCompletion?) {

        geocoder.geocodeAddressString(searchText, completionHandler: { (placemarks, error) -> Void in

            if let actualPlacemarks = placemarks {
                var suggestedResults: [Place] = []
                if !actualPlacemarks.isEmpty {
                    for placemark in actualPlacemarks {
                        suggestedResults.append(placemark.place())
                    }
                }
                completion?(SearchLocationSuggestionsServiceResult(value: suggestedResults))
            }
            // Error
            else if let actualError = error {
                if actualError.code == CLError.GeocodeFoundNoResult.rawValue {
                    completion?(SearchLocationSuggestionsServiceResult(error: .NotFound))
                } else {
                    completion?(SearchLocationSuggestionsServiceResult(error: .Network))
                }
            }
            else {
                completion?(SearchLocationSuggestionsServiceResult(error: .Internal))
            }
        })
    }

}
