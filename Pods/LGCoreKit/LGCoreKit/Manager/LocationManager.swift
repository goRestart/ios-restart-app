//
//  LocationManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import LGCoreKit
import Result

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
    public static let didMoveFromManualLocationNotification = "LocationManager.didMoveFromManualLocationNotificationn"
    
    // > Location Service setup
    public static let distanceFilter: CLLocationDistance = 250
    public static let desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters
    
    // Singleton
    public static let sharedInstance: LocationManager = LocationManager()
    
    // iVars
    private var locationService: LocationService
    
    private var lastManualLocation: CLLocation?
    public private(set) var lastGPSLocation: CLLocation?
    public private(set) var isManualLocation : Bool
    
    public var lastKnownLocation: CLLocation? {
        return isManualLocation ? lastManualLocation : lastGPSLocation
    }
    
    public var locationEnabled: Bool {
        return self.locationService.locationEnabled()
    }
    
    public var locationServiceStatus: LocationServiceStatus {
        return LocationServiceStatus(enabled: self.locationService.locationEnabled(), authStatus: self.locationService.authorizationStatus())
    }
    
    // MARK: - Lifecycle
    
    public init(locationService: LocationService = CLLocationManager()) {
        self.locationService = locationService
        
        self.lastGPSLocation = self.locationService.lastKnownLocation
        self.lastManualLocation = UserDefaultsManager.sharedInstance.loadManualLocation()
        
        self.isManualLocation = UserDefaultsManager.sharedInstance.loadIsManualLocation() ?? false
        
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
    
    public func userDidSetManualLocation(location: CLLocation, postalAddress: PostalAddress?) {
        UserDefaultsManager.sharedInstance.saveIsManualLocation(true)
        isManualLocation = true
        // save location to userdefaults
        
        lastManualLocation = location
        UserDefaultsManager.sharedInstance.saveManualLocation(lastManualLocation!)
        if let location = lastKnownLocation {
            MyUserManager.sharedInstance.saveUserCoordinates(location.coordinate, result: { (result: Result<CLLocationCoordinate2D, SaveUserCoordinatesError>) in }, postalAddress: postalAddress)
        }
    }
    
    public func userDidSetAutomaticLocation(postalAddress: PostalAddress?) {
        UserDefaultsManager.sharedInstance.saveIsManualLocation(false)
        isManualLocation = false
        if let location = lastKnownLocation {
            MyUserManager.sharedInstance.saveUserCoordinates(location.coordinate, result: { (result: Result<CLLocationCoordinate2D, SaveUserCoordinatesError>) in }, postalAddress: postalAddress)
        }
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
            self.lastGPSLocation = lastLocation

            if isManualLocation && lastLocation.distanceFromLocation(lastManualLocation) > LGCoreKitConstants.maxDistanceToAskUpdateLocation {
                NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didMoveFromManualLocationNotification, object: lastLocation)
            }
            
            if !isManualLocation {
                NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didReceiveLocationNotification, object: lastLocation)
            }
        }
    }
}

