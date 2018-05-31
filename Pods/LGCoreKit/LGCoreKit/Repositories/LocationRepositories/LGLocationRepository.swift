import CoreLocation
import Result

public class LGLocationRepository: LocationRepository {

    let appleLocationDataSource: LocationDataSource
    let niordLocationDataSource: LocationDataSource
    let ipLookupDataSource: IPLookupDataSource
    var clLocationManager: CLLocationManagerProtocol
    public var emergencyIsActive: Bool = false
    
    // MARK: - Lifecycle

    public init(appleLocationDataSource: LocationDataSource,
                niordLocationDataSource: LocationDataSource,
                ipLookupDataSource: IPLookupDataSource,
                locationManager: CLLocationManagerProtocol) {
        self.appleLocationDataSource = appleLocationDataSource
        self.niordLocationDataSource = niordLocationDataSource
        self.ipLookupDataSource = ipLookupDataSource
        self.clLocationManager = locationManager
    }
    
    // MARK: - LocationRepository
    
    public var distance: CLLocationDistance {
        get {
            return clLocationManager.distanceFilter
        }
        set {
            clLocationManager.distanceFilter = newValue
        }
    }
    public var accuracy: CLLocationAccuracy {
        get {
            return clLocationManager.desiredAccuracy
        }
        set {
            clLocationManager.desiredAccuracy = newValue
        }
    }
    public var lastKnownLocation: CLLocation? {
        get {
            return clLocationManager.location
        }
    }
    
    public func setLocationManagerDelegate(delegate: CLLocationManagerDelegate) {
        clLocationManager.delegate = delegate
    }
    
    public func locationEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    public func authorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    public func requestWhenInUseAuthorization() {
        clLocationManager.requestWhenInUseAuthorization()
    }
    
    public func requestAlwaysAuthorization() {
        clLocationManager.requestAlwaysAuthorization()
    }
    
    public func startUpdatingLocation() {
        clLocationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        clLocationManager.stopUpdatingLocation()
    }

    public func startEmergencyLocation() {
        emergencyIsActive = true
        clLocationManager.allowsBackgroundLocationUpdates  = true
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        clLocationManager.startUpdatingLocation()
    }

    public func stopEmergencyLocation() {
        clLocationManager.allowsBackgroundLocationUpdates = false
        clLocationManager.desiredAccuracy = LGCoreKitConstants.locationDesiredAccuracy
        clLocationManager.stopUpdatingLocation()
        emergencyIsActive = false
    }
    
    public func retrieveLocationSuggestions(addressString: String,
                                            currentLocation: LGLocation?,
                                            completion: LocationSuggestionsRepositoryCompletion?) {
        guard !addressString.isEmpty else {
            completion?(LocationSuggestionsRepositoryResult(error: LocationError.notFound))
            return
        }
        let region = makeCircularRegion(withLocation: currentLocation)
        niordLocationDataSource.retrieveLocationSuggestions(addressString: addressString, region: region) { result in
            if let value = result.value {
                completion?(LocationSuggestionsRepositoryResult(value: value))
            } else if let error = result.error {
                completion?(LocationSuggestionsRepositoryResult(error: error))
            }
        }
    }
    
    public func retrieveLocationSuggestionDetails(placeId: String, 
                                                  completion: LocationSuggestionDetailsRepositoryCompletion?) {
        guard !placeId.isEmpty else {
            completion?(LocationSuggestionDetailsRepositoryResult(error: LocationError.notFound))
            return
        }
        niordLocationDataSource.retrieveLocationSuggestionDetails(placeId: placeId) { result in
            if let value = result.value {
                completion?(LocationSuggestionDetailsRepositoryResult(value: value))
            } else if let error = result.error {
                completion?(LocationSuggestionDetailsRepositoryResult(error: error))
            }
        }
    }
    
    public func retrievePostalAddress(location: LGLocationCoordinates2D,
                                      completion: PostalAddressLocationRepositoryCompletion?) {
        // Using only Apple geocode. We make too many geocode requests to use Niord
        appleLocationDataSource.retrievePostalAddress(location: location) { [weak self] result in
            guard let value = result.value else {
                self?.niordLocationDataSource.retrievePostalAddress(location: location, completion: completion)
                return
            }
            completion?(PostalAddressLocationRepositoryResult(value: value))
        }
    }
    
    public func retrieveIPLookupLocation(completion: IPLookupLocationRepositoryCompletion?) {
        ipLookupDataSource.retrieveIPLookupLocation { (result) in
            if let value = result.value {
                completion?(IPLookupLocationRepositoryResult(value: value))
            } else if let error = result.error {
                completion?(IPLookupLocationRepositoryResult(error: error))
            }
        }
    }


    // MARK: - Helpers
    
    private func makeCircularRegion(withLocation location: LGLocation?) -> CLCircularRegion? {
        guard let location = location else { return nil }
        return CLCircularRegion(center: location.coordinate,
                                radius: LGCoreKitConstants.geocodeRegionRadius,
                                identifier: "search region")
    }
}

