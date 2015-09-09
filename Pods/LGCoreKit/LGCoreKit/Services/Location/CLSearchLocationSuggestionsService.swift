//
//  CLSearchLocationSuggestionsService.swift
//  LGCoreKit
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result

public enum SearchLocationSuggestionsServiceError {
    case Network
    case Internal
    case UnknownLocation
}

public typealias SearchLocationSuggestionsServiceResult = (Result<[Place], SearchLocationSuggestionsServiceError>) -> Void

public class CLSearchLocationSuggestionsService {
   
    // iVars
    private var geocoder: CLGeocoder
    
    // MARK: - Lifecycle
    
    public init() {
        geocoder = CLGeocoder()
    }
    
    // MARK: - PostalAddressRetrievalService
    
    public func retrieveAddressForLocation(searchText: String, result: SearchLocationSuggestionsServiceResult?) {
        
        geocoder.geocodeAddressString(searchText, completionHandler: { (placemarks, error) -> Void in
            
            if let actualPlacemarks = placemarks as? [CLPlacemark] {
                var suggestedResults: [Place] = []
                if !actualPlacemarks.isEmpty {
                    for placemark in actualPlacemarks {
                        suggestedResults.append(placemark.place())
                    }
                }
                result?(Result<[Place], SearchLocationSuggestionsServiceError>.success(suggestedResults))
            }
                // Error
            else if let actualError = error {
                if error.code == CLError.GeocodeFoundNoResult.rawValue {
                    result?(Result<[Place], SearchLocationSuggestionsServiceError>.failure(.UnknownLocation))
                } else {
                    result?(Result<[Place], SearchLocationSuggestionsServiceError>.failure(.Network))
                }
            }
            else {
                result?(Result<[Place], SearchLocationSuggestionsServiceError>.failure(.Internal))
            }
        })
    }
    
}
