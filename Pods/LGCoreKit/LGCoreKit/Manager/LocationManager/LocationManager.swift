//
//  LocationManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 28/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import CoreLocation
import Result

protocol LocationManagerDelegate: class {
    func locationManager(locationManager: LocationManager, didUpdateAutoLocation location: LGLocation)
}

public protocol LocationManagerPermissionDelegate: class {
    func locationManager(locationManager: LocationManager, didAcceptPermission accepted: Bool)
}


public class LocationManager: NSObject, CLLocationManagerDelegate {

    // Managers & services
    private var sensorLocationService: LocationService
    private let ipLookupLocationService: IPLookupLocationService
    private let countryHelper: CountryHelper

    // iVars
    private var sensorLocation: LGLocation?
    private var inaccurateLocation: LGLocation?
    var manualLocation: LGLocation?     // If set, then manual location is enabled

    // Helper
    var isManualLocationEnabled: Bool {
        return manualLocation != nil
    }

    // Delegate
    weak var delegate: LocationManagerDelegate?
    weak var permissionDelegate: LocationManagerPermissionDelegate?

    /**
    Returns the current location. If manual, then the manual location, if any. Otherwise, the automatic location.
    */
    var currentLocation: LGLocation? {
        if manualLocation != nil {
            return manualLocation
        }
        return currentAutoLocation
    }

    /**
    Returns the best accurate automatic location.
    */
    var currentAutoLocation: LGLocation? {
        if sensorLocation != nil {
            return sensorLocation
        }
        return inaccurateLocation
    }

    /**
    Returns the current location service status.
    */
    var locationServiceStatus: LocationServiceStatus {
        return LocationServiceStatus(enabled: sensorLocationService.locationEnabled(),
            authStatus: sensorLocationService.authorizationStatus())
    }

    public required init(sensorLocationService: LocationService, ipLookupLocationService: IPLookupLocationService,
        countryHelper: CountryHelper) {
            // Managers & services
            self.sensorLocationService = sensorLocationService
            self.ipLookupLocationService = ipLookupLocationService
            self.countryHelper = countryHelper

            // iVars
            if let lastKnownLocation = sensorLocationService.lastKnownLocation {
                self.sensorLocation = LGLocation(location: lastKnownLocation, type: .Sensor)
            }

            super.init()

            // Setup
            self.sensorLocationService.locationManagerDelegate = self

            // Start retrieving inaccurate location (iplookup with regional fallback)
            retrieveInaccurateLocation()
    }

    public convenience override init() {
        let sensorLocationService = CLLocationManager()
        sensorLocationService.distance = LGCoreKitConstants.locationDistanceFilter
        sensorLocationService.accuracy = LGCoreKitConstants.locationDesiredAccuracy

        let ipLookupLocationService = LGIPLookupLocationService()
        let countryHelper = CountryHelper()
        self.init(sensorLocationService: sensorLocationService, ipLookupLocationService: ipLookupLocationService,
            countryHelper: countryHelper)
    }

    // MARK: - Public methods

    // MARK: > Sensor location

    /**
    Starts updating sensor location.

    - returns: The location service status.
    */
    public func startSensorLocationUpdates() -> LocationServiceStatus {
        let enabled = sensorLocationService.locationEnabled()
        let authStatus = sensorLocationService.authorizationStatus()

        if enabled {
            // If not determined, ask authorization
            if authStatus == .NotDetermined {
                sensorLocationService.requestWhenInUseAuthorization()
            }
                // Otherwise, start the location updates
            else {
                sensorLocationService.startUpdatingLocation()
            }
        }
        return LocationServiceStatus(enabled: enabled, authStatus: authStatus)
    }

    /**
    Stops updating location.
    */
    public func stopSensorLocationUpdates() {
        sensorLocationService.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            // Start the location updates
            sensorLocationService.startUpdatingLocation()

            permissionDelegate?.locationManager(self, didAcceptPermission: true)

        case .Restricted, .Denied:
            permissionDelegate?.locationManager(self, didAcceptPermission: false)
        case .NotDetermined:
            break
        }
    }

    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {

            // Update last gps location
            sensorLocation = LGLocation(location: lastLocation, type: .Sensor)

            // Notify the delegate
            delegate?.locationManager(self, didUpdateAutoLocation: sensorLocation!)
        }
    }

    // MARK: - Private methods

    /**
    Requests the IP lookup location retrieval and, if fails it uses the regional.
    */
    private func retrieveInaccurateLocation() {
        ipLookupLocationService.retrieveLocationWithCompletion {
            [weak self] (result: IPLookupLocationServiceResult) -> Void in
            if let strongSelf = self {
                // If there's no previous location it should notify
                var shouldNotify = strongSelf.currentLocation == nil

                // Success
                if let coordinates = result.value {
                    strongSelf.inaccurateLocation = LGLocation(location: CLLocation(latitude: coordinates.latitude,
                        longitude: coordinates.longitude), type: .IPLookup)
                }
                    // Error
                else {
                    strongSelf.inaccurateLocation = strongSelf.retrieveRegionalLocational()
                }

                // If the current location is not the same as the one received then we notify the delegate
                shouldNotify = shouldNotify ||
                    strongSelf.currentLocation?.location != strongSelf.inaccurateLocation?.location
                if shouldNotify {
                    strongSelf.delegate?.locationManager(strongSelf, didUpdateAutoLocation: strongSelf.currentLocation!)
                }
            }
        }
    }

    /**
    Requests the regional location.

    - returns: The regional location.
    */
    private func retrieveRegionalLocational() -> LGLocation {
        let coordinate = countryHelper.regionCoordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return LGLocation(location: location, type: .Regional)
    }
}
