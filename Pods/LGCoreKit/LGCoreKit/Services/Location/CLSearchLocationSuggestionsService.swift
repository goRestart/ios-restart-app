//
//  CLSearchLocationSuggestionsService.swift
//  LGCoreKit
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result

public enum SearchLocationSuggestionsServiceError: Error {
    case network
    case internalError
    case notFound
}

public typealias SearchLocationSuggestionsServiceResult = Result<[Place], SearchLocationSuggestionsServiceError>
public typealias SearchLocationSuggestionsServiceCompletion = (SearchLocationSuggestionsServiceResult) -> Void

public class CLSearchLocationSuggestionsService {

    // iVars
    private var geocoder: CLGeocoder

    // MARK: - Lifecycle

    public init() {
        geocoder = CLGeocoder()
    }

    // MARK: - PostalAddressRetrievalService

    public func retrieveAddressForLocation(_ searchText: String, completion: SearchLocationSuggestionsServiceCompletion?) {

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
                if actualError._code == CLError.Code.geocodeFoundNoResult.rawValue {
                    completion?(SearchLocationSuggestionsServiceResult(error: .notFound))
                } else {
                    completion?(SearchLocationSuggestionsServiceResult(error: .network))
                }
            }
            else {
                completion?(SearchLocationSuggestionsServiceResult(error: .internalError))
            }
        })
    }

}
