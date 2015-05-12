//
//  LocationManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public enum LocationServicesAuthStatus {
    case NotDetermined
    case Restricted
    case Denied
    case Authorized
}

public enum LocationServiceStatus: Equatable {
    case Disabled
    case Enabled(LocationServicesAuthStatus)
    
    public init(enabled: Bool, authStatus: CLAuthorizationStatus) {
        if !enabled {
            self = .Disabled
        }
        else {
            switch authStatus {
            case .NotDetermined:
                self = Enabled(.NotDetermined)
            case .Restricted:
                self = Enabled(.Restricted)
            case .Denied:
                self = Enabled(.Denied)
            case .AuthorizedAlways:
                self = Enabled(.Authorized)
            case .AuthorizedWhenInUse:
                self = Enabled(.Authorized)
            default:
                self = Enabled(.Authorized)
            }
        }
    }
}

public func ==(lhs: LocationServiceStatus, rhs: LocationServiceStatus) -> Bool {
    
    switch (lhs, rhs) {
    case (.Disabled, .Disabled):
        return true
    case (.Enabled(let rAuthStatus), .Enabled(let lAuthStatus)):
        return rAuthStatus == lAuthStatus
    default:
        return false
    }
}

public class LocationManager: NSObject, CLLocationManagerDelegate {

    // Constants
    // > Notifications
    public static let didReceiveLocationNotification = "LocationManager.didReceiveLocationNotification"
    public static let didFailRequestingLocationServices = "LocationManager.didFailRequestingLocationServices"
    
    // > Location Service setup
    public static let distanceFilter: CLLocationDistance = 250
    public static let desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters
    
    // Singleton
    public static let sharedInstance: LocationManager = LocationManager()
    
    // iVars
    private var locationService: LocationService
    private var userDefaults: NSUserDefaults
    
    public private(set) var lastKnownLocation: CLLocation?
    
    public var locationEnabled: Bool {
        return self.locationService.locationEnabled()
    }
    
    public var locationServiceStatus: LocationServiceStatus {
        return LocationServiceStatus(enabled: self.locationService.locationEnabled(), authStatus: self.locationService.authorizationStatus())
    }
    
    // MARK: - Lifecycle
    
    public init(locationService: LocationService = CLLocationManager(), userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        self.locationService = locationService
        self.userDefaults = userDefaults
        self.lastKnownLocation = self.locationService.lastKnownLocation
        super.init()
        
        // Setup
        self.locationService.distance = LocationManager.distanceFilter
        self.locationService.accuracy = LocationManager.desiredAccuracy
        self.locationService.locationManagerDelegate = self
    }
    
    // MARK: - Public methods
    
    /**
        Starts updating location.
    
        :returns: The current location service status.
    */
    public func startLocationUpdates() -> LocationServiceStatus {
        
        // If LBS are not enabled then notify about it
        if !self.locationService.locationEnabled() {
            NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didFailRequestingLocationServices, object: nil)
        }
        
        // Check the current status, then if iOS 8 we should request permissions
        let status = locationServiceStatus
        switch status {
        case .Enabled(let authStatus):
            switch authStatus {
            case .NotDetermined:
                if UIDevice.isOSAtLeast(OSVersion.iOS8_0_0) {
                    self.locationService.requestWhenInUseAuthorization()
                }
            default:
                break
            }
        default:
            break
        }
        
        // Start updating the location
        self.locationService.startUpdatingLocation()
        
        return status
    }
    
    /**
        Stops updating location.
    */
    public func stopLocationUpdates() {
        self.locationService.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        let locationStatus = LocationServiceStatus(enabled: self.locationService.locationEnabled(), authStatus: self.locationService.authorizationStatus())
        
        if locationStatus == .Enabled(LocationServicesAuthStatus.Authorized) {
            self.locationService.startUpdatingLocation()
        }
        else {
            NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didFailRequestingLocationServices, object: nil)
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let actualLocations = locations, let lastLocation = actualLocations.last as? CLLocation {
            self.lastKnownLocation = lastLocation
            
            NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didReceiveLocationNotification, object: lastLocation)
        }
    }
}

