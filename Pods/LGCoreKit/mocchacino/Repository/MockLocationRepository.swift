import CoreLocation

open class MockLocationRepository: LocationRepository {

    public var suggestionsResult: LocationSuggestionsRepositoryResult!
    public var suggestionDetailsResult: LocationSuggestionDetailsRepositoryResult!
    public var postalAddressResult: PostalAddressLocationRepositoryResult!
    public var ipLookupLocationResult: IPLookupLocationRepositoryResult!

    public var locationEnabledValue: Bool = true
    public var emergencyIsActive: Bool = false

    public var authorizationStatusValue: CLAuthorizationStatus = .notDetermined

    var retrieveLocationSuggestionsCalled: Bool = false
    var retrieveLocationSuggestionDetailsCalled: Bool = false
    var retrievePostalAddressCalled: Bool = false
    var retrieveIPLookupLocationCalled: Bool = false

    // MARK: - Lifecycle
    
    required public init() {
        
    }
    
    public var distance: CLLocationDistance = 20
    public var accuracy: CLLocationAccuracy = 20
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
    public func startUpdatingLocation() {}
    public func stopUpdatingLocation() {}
    public func startEmergencyLocation() {}
    public func stopEmergencyLocation() {}

    
    public func retrieveLocationSuggestions(addressString: String, currentLocation: LGLocation?, completion: LocationSuggestionsRepositoryCompletion?) {
        retrieveLocationSuggestionsCalled = true
        delay(result: suggestionsResult, completion: completion)
    }
    
    public func retrieveLocationSuggestionDetails(placeId: String, completion: LocationSuggestionDetailsRepositoryCompletion?) {
        retrieveLocationSuggestionDetailsCalled = true
        delay(result: suggestionDetailsResult, completion: completion)
    }
    
    public func retrievePostalAddress(location: LGLocationCoordinates2D, completion: PostalAddressLocationRepositoryCompletion?) {
        retrievePostalAddressCalled = true
        delay(result: postalAddressResult, completion: completion)
    }
    
    public func retrieveIPLookupLocation(completion: IPLookupLocationRepositoryCompletion?) {
        retrieveIPLookupLocationCalled = true
        delay(result: ipLookupLocationResult, completion: completion)
    }
}
 
