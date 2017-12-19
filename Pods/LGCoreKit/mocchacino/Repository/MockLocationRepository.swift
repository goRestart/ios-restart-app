//
//  MockPostalAddressRetrievalRepository.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 20/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

open class MockLocationRepository: LocationRepository {
    
    public var suggestionsResult: LocationSuggestionsRepositoryResult!
    public var suggestionDetailsResult: LocationSuggestionDetailsRepositoryResult!
    public var postalAddressResult: PostalAddressLocationRepositoryResult!
    public var ipLookupLocationResult: IPLookupLocationRepositoryResult!
    
    public var locationEnabledValue: Bool = true
    public var authorizationStatusValue: CLAuthorizationStatus = .notDetermined
    
    public var locationDataSourceType: LocationDataSourceType = .apple(shouldUseRegion: false)
    
    // MARK: - Lifecycle
    
    required public init() {
        
    }
    
    public var distance: CLLocationDistance = 20
    public var accuracy: CLLocationDistance = 20
    public var lastKnownLocation: CLLocation?
    
    public func setLocationManagerDelegate(delegate: CLLocationManagerDelegate) {}
    public func setLocationDataSourceType(locationDataSourceType: LocationDataSourceType) {}
    
    public func locationEnabled() -> Bool {
        return locationEnabledValue
    }
    
    public func authorizationStatus() -> CLAuthorizationStatus {
        return authorizationStatusValue
    }
    
    public func requestWhenInUseAuthorization() {}
    
    public func requestAlwaysAuthorization() {}
    public func startUpdatingLocation() { }
    
    public func stopUpdatingLocation() { }
    
    public func retrieveLocationSuggestions(addressString: String, currentLocation: LGLocation?, completion: LocationSuggestionsRepositoryCompletion?) {
        delay(result: suggestionsResult, completion: completion)
    }
    
    public func retrieveLocationSuggestionDetails(placeId: String, completion: LocationSuggestionDetailsRepositoryCompletion?) {
        delay(result: suggestionDetailsResult, completion: completion)
    }
    
    public func retrievePostalAddress(location: LGLocationCoordinates2D, completion: PostalAddressLocationRepositoryCompletion?) {
        delay(result: postalAddressResult, completion: completion)
    }
    
    public func retrieveIPLookupLocation(completion: IPLookupLocationRepositoryCompletion?) {
        delay(result: ipLookupLocationResult, completion: completion)
    }
}
 
