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
    public static let DidReceiveLocationNotification = "LocationManagerDidReceiveLocationNotification"
    
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
        self.locationService.distance = 250
        self.locationService.accuracy = kCLLocationAccuracyHundredMeters
        self.locationService.locationManagerDelegate = self
    }
    
    // MARK: - Public methods
    
    public func startLocationUpdates() -> LocationServiceStatus {
        
        let status = locationServiceStatus
        switch status {
        case .Enabled(let authStatus):
            switch authStatus {
            case .NotDetermined:
                if UIDevice.isOSAtLeast(OSVersion.iOS8_0_0) {
                    self.locationService.requestWhenInUseAuthorization()
                }
                else {
                    self.locationService.startUpdatingLocation()
                }
            case .Authorized:
                self.locationService.startUpdatingLocation()
            default:
                break
            }
        default:
            break
        }
        
        return status
    }
    
    public func stopLocationUpdates() {
        self.locationService.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        let locationStatus = LocationServiceStatus(enabled: self.locationService.locationEnabled(), authStatus: self.locationService.authorizationStatus())
        
        switch locationStatus {
        case .Enabled(let authStatus):
            switch authStatus {
            case .Authorized:
                self.locationService.startUpdatingLocation()
            default:
                break
            }
        default:
            break
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let actualLocations = locations, let lastLocation = actualLocations.last as? CLLocation {
            self.lastKnownLocation = lastLocation
            
            NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.DidReceiveLocationNotification, object: lastLocation)
        }
    }
}

