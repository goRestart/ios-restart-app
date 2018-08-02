//
//  LGAppleLocationDataSource.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 26/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import CoreLocation

class LGAppleLocationDataSource: LocationDataSource {
    
    private let geocoder: CLGeocoder

    // MARK: - Lifecycle
    
    public init() {
        geocoder = CLGeocoder()
    }
    
    // MARK: - LocationDataSource
    
    public func retrieveLocationSuggestions(addressString: String,
                                            region: CLCircularRegion?,
                                            completion: SuggestionsLocationDataSourceCompletion?) {
        geocoder.geocodeAddressString(addressString, in: region) { (placemarks, error) in
            if let actualPlacemarks = placemarks {
                let suggestedResults: [Place] = actualPlacemarks.compactMap { $0.place() }
                completion?(SuggestionsLocationDataSourceResult(value: suggestedResults))
            } else if let actualError = error {
                if actualError._code == CLError.Code.geocodeFoundNoResult.rawValue {
                    completion?(SuggestionsLocationDataSourceResult(error: .notFound))
                } else {
                    completion?(SuggestionsLocationDataSourceResult(error: .network))
                }
            } else {
                completion?(SuggestionsLocationDataSourceResult(error: .internalError))
            }
        }
    }
    
    func retrievePostalAddress(location: LGLocationCoordinates2D,
                               completion: PostalAddressLocationDataSourceCompletion?) {
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.last {
                let place = placemark.place()
                completion?(PostalAddressLocationDataSourceResult(value: place))
            } else if let _ = error {
                completion?(PostalAddressLocationDataSourceResult(error: .network))
            } else {
                completion?(PostalAddressLocationDataSourceResult(error: .internalError))
            }
        }
    }
    
    func retrieveLocationSuggestionDetails(placeId: String,
                                            completion: SuggestionLocationDetailsDataSourceCompletion?){
        // Apple geocode does not need to retrieve place details
    }
}
