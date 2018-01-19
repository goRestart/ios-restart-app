//
//  LocationRepository.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 27/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Result
import CoreLocation

public typealias LocationSuggestionsRepositoryResult = Result<[Place], LocationError>
public typealias LocationSuggestionsRepositoryCompletion = (LocationSuggestionsRepositoryResult) -> Void

public typealias LocationSuggestionDetailsRepositoryResult = Result<Place, LocationError>
public typealias LocationSuggestionDetailsRepositoryCompletion = (LocationSuggestionDetailsRepositoryResult) -> Void

public typealias PostalAddressLocationRepositoryResult = Result<Place, LocationError>
public typealias PostalAddressLocationRepositoryCompletion = (PostalAddressLocationRepositoryResult) -> Void

public typealias IPLookupLocationRepositoryResult = Result<LGLocationCoordinates2D, IPLookupLocationError>
public typealias IPLookupLocationRepositoryCompletion = (IPLookupLocationRepositoryResult) -> Void


public protocol LocationRepository {
    
    var distance: CLLocationDistance { get set }
    var accuracy: CLLocationDistance { get set }
    var lastKnownLocation: CLLocation? { get }
    
    func setLocationManagerDelegate(delegate: CLLocationManagerDelegate)
    
    func locationEnabled() -> Bool
    func authorizationStatus() -> CLAuthorizationStatus
    
    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
    
    func startUpdatingLocation()
    func stopUpdatingLocation()
    
    func retrieveLocationSuggestions(addressString: String, currentLocation: LGLocation?, completion: LocationSuggestionsRepositoryCompletion?)
    func retrieveLocationSuggestionDetails(placeId: String, completion: LocationSuggestionDetailsRepositoryCompletion?)
    func retrievePostalAddress(location: LGLocationCoordinates2D, completion: PostalAddressLocationRepositoryCompletion?)
    func retrieveIPLookupLocation(completion: IPLookupLocationRepositoryCompletion?)
}

