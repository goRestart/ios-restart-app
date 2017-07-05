//
//  MockPostalAddressRetrievalRepository.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 20/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

open class MockLocationRepository: LocationRepository {

    public var suggestionsResult: SuggestionsLocationRepositoryResult!
    public var postalAddressResult: PostalAddressLocationRepositoryResult!
    public var ipLookupLocationResult: IPLookupLocationRepositoryResult!
    
    public var locationEnabledValue: Bool = true
    public var authorizationStatusValue: CLAuthorizationStatus = .notDetermined
    
    // MARK: - Lifecycle
    
    required public init() {
        
    }
    
    public var distance: CLLocationDistance = 20
    public var accuracy: CLLocationDistance = 20
    public var lastKnownLocation: CLLocation?
    
    public func setLocationManagerDelegate(delegate: CLLocationManagerDelegate) {}
    
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
    
    public func retrieveAddressForLocation(_ location: LGLocationCoordinates2D, completion: PostalAddressLocationRepositoryCompletion?) {
        delay(result: postalAddressResult, completion: completion)
    }
    
    public func retrieveAddressForLocation(_ searchText: String, completion: SuggestionsLocationRepositoryCompletion?) {
        delay(result: suggestionsResult, completion: completion)
    }
    
    public func retrieveLocationWithCompletion(_ completion: IPLookupLocationRepositoryCompletion?) {
        delay(result: ipLookupLocationResult, completion: completion)
    }
}
 
