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

public enum LGLocationType: String {
    case Manual     = "manual"
    case Sensor     = "sensor"
    case IPLookup   = "iplookup"
    case LastSaved  = "lastsaved"
}

public class LGLocation: Printable {
    
    public private(set) var location : CLLocation
    public private(set) var type: LGLocationType
    
    public init(location: CLLocation, type: LGLocationType) {
        self.location = location
        self.type = type
    }
    
    public var description : String {
        return "location: \(location.description); type: \(type.rawValue)"
    }
}

public class LocationManager: NSObject, CLLocationManagerDelegate {

    // Constants & enums
    // > Notifications
    public static let didReceiveLocationNotification = "LocationManager.didReceiveLocationNotification"
    public static let didFailRequestingLocationServices = "LocationManager.didFailRequestingLocationServices"
    public static let didMoveFromManualLocationNotification = "LocationManager.didMoveFromManualLocationNotification"
    public static let didTimeOutRetrievingLocation = "LocationManager.didTimeOutRetrievingLocation"
    
    // > Location Service setup
    public static let distanceFilter: CLLocationDistance = 250
    public static let desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters
    
    // Singleton
    public static let sharedInstance: LocationManager = LocationManager()
    
    // iVars
    // > Services
    private var locationService: LocationService
    private var ipLookupLocationService: IPLookupLocationService
    
    // > Data
    public private(set) var lastGPSLocation: LGLocation?
    private var lastIPLookupLocationResult: Result<LGLocationCoordinates2D, IPLookupLocationServiceError>?
    private var lastManualLocation: LGLocation?
    public private(set) var isManualLocation : Bool
    public private(set) var locationRetrievalDidTimeOut: Bool
    
    private var gpsLocationRetrievalTimeoutTimer: NSTimer?
    
    public var lastKnownLocation: LGLocation? {
        // If it's forced manual & we've it, then return it
        if isManualLocation && lastManualLocation != nil {
            return lastManualLocation
        }
        // Otherwise, if we have GPS location, then return it
        else if lastGPSLocation != nil {
            return lastGPSLocation
        }
        // Otherwise, if we have IP look up location, then return it
        else if let lastIPLookupLocation = lastIPLookupLocationResult?.value {
            let location = CLLocation(latitude: lastIPLookupLocation.latitude, longitude: lastIPLookupLocation.longitude)
            return LGLocation(location: location, type: .IPLookup)
        }
        // Otherwise, if the user has an already saved coordinates then return it
        else if let savedUserCoordinates = MyUserManager.sharedInstance.myUser()?.gpsCoordinates {
            let location = CLLocation(latitude: savedUserCoordinates.latitude, longitude: savedUserCoordinates.longitude)
            return LGLocation(location: location, type: .LastSaved)
        }
        return nil
    }
    
    public var locationEnabled: Bool {
        return locationService.locationEnabled()
    }
    
    public var locationServiceStatus: LocationServiceStatus {
        return LocationServiceStatus(enabled: locationService.locationEnabled(), authStatus: locationService.authorizationStatus())
    }
    
    // MARK: - Lifecycle
    
    public init(locationService: LocationService, ipLookupLocationService: IPLookupLocationService) {
        self.locationService = locationService
        self.ipLookupLocationService = ipLookupLocationService
        
        if let lastKnownLocation = self.locationService.lastKnownLocation {
            self.lastGPSLocation = LGLocation(location: self.locationService.lastKnownLocation, type: .Sensor)
        }
        if let manualLocation = UserDefaultsManager.sharedInstance.loadManualLocation() {
            self.lastManualLocation = LGLocation(location: manualLocation, type: .Manual)
        }
        
        self.isManualLocation = UserDefaultsManager.sharedInstance.loadIsManualLocation() ?? false
        self.locationRetrievalDidTimeOut = false
        
        super.init()
        
        // Setup
        self.locationService.distance = LocationManager.distanceFilter
        self.locationService.accuracy = LocationManager.desiredAccuracy
        self.locationService.locationManagerDelegate = self
        
        // Retrieve the IP look up location
        retrieveIPLookupLocation()
        
        // NSNotification Center: observe when app is going/coming to/from background
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationDidEnterBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillEnterForeground:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    public override convenience init() {
        let locationService = CLLocationManager()
        let ipLookupLocationService = LGIPLookupLocationService()
        self.init(locationService: locationService, ipLookupLocationService: ipLookupLocationService)
    }
    
    // MARK: - Public methods
    
    /**
        Starts updating location.
    */
    public func startLocationUpdates() {
        
        // If LBS are enabled then start updating the location
        if locationService.locationEnabled() {
            locationService.startUpdatingLocation()
        }
        // Otherwise,
        else {
            // Start the location retrieval timer
            restartTimer()
            
            // Notify about it
            NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didFailRequestingLocationServices, object: nil)
        }
        
        // If current LBS status is not determined then request authorization
        switch locationServiceStatus {
        case .Enabled(let authStatus):
            switch authStatus {
            case .NotDetermined:
                locationService.requestWhenInUseAuthorization()
            case .Restricted, .Denied, .Authorized:
                break
            }
        case .Disabled:
            break
        }
    }
    
    /**
        Stops updating location.
    */
    public func stopLocationUpdates() {
        locationService.stopUpdatingLocation()
    }
    
    /**
        Called when the user does not allow LBS.
    */
    public func userDoesntAllowLocationServices() {
        
    }
    
    /**
        Called when the user sets manual location.
    
        :param: location The location.
        :param: place The place linked with the location.
    */
    public func userDidSetManualLocation(location: CLLocation, place: Place?) {
        UserDefaultsManager.sharedInstance.saveIsManualLocation(true)
        isManualLocation = true
        // save location to userdefaults
        
        lastManualLocation = LGLocation(location: location, type: .Manual)
        UserDefaultsManager.sharedInstance.saveManualLocation(lastManualLocation!.location)

        saveMyLastKnownLocationAndPlace(place)
    }
    
    /**
        Called when the user sets a location.
    
        :param: place A linked place with the location.
    */
    public func userDidSetAutomaticLocation(place: Place?) {
        UserDefaultsManager.sharedInstance.saveIsManualLocation(false)
        isManualLocation = false
        
        saveMyLastKnownLocationAndPlace(place)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch locationServiceStatus {
        case .Enabled(let authStatus):
            switch authStatus {
            case .Authorized:
                // Start updating location
                locationService.startUpdatingLocation()
                
                // Start the location retrieval timer
                restartTimer()
            
            case .NotDetermined:
                // Notify about it
                NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didFailRequestingLocationServices, object: nil)
                
                // Do not start the timer as we wait for the user response, that calls this method again
            case .Restricted, .Denied:
                // Notify about it
                NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didFailRequestingLocationServices, object: nil)

                // If the ip lookup finished with a failure, then it's like a location timeout as we have nothing to do
                if let ipLookupResult = lastIPLookupLocationResult, let error = ipLookupResult.error {
                    locationRetrievalTimedOut()
                }
                // Otherwise, start the location retrieval timer
                else {
                    restartTimer()
                }
            }
        case .Disabled:
            // Notify about it
            NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didFailRequestingLocationServices, object: nil)
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let actualLocations = locations, let lastLocation = actualLocations.last as? CLLocation {
            
            // Update last gps location
            lastGPSLocation = LGLocation(location: lastLocation, type: .Sensor)

            // If it's manual
            if isManualLocation {
                // and the user moved +1 Km then notify about it
                if lastLocation.distanceFromLocation(lastManualLocation?.location) > LGCoreKitConstants.maxDistanceToAskUpdateLocation{
                    NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didMoveFromManualLocationNotification, object: lastGPSLocation)
                }
            }
            // Otherwise, notify about location updates
            else {
                NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didReceiveLocationNotification, object: lastGPSLocation)
            }
        }
    }
    
    // MARK: - Private methods
    
    // MARK: > Helper
    
    /**
        Requests the IP lookup location retrieval.
    */
    private func retrieveIPLookupLocation() {
        ipLookupLocationService.retrieveLocation { [weak self] (result: Result<LGLocationCoordinates2D, IPLookupLocationServiceError>) -> Void in

            // Keep track of the result
            self?.lastIPLookupLocationResult = result
            
            // Success, then notify about it
            if let coordinates = result.value {
                let location = LGLocation(location: CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude), type: .IPLookup)
                NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didReceiveLocationNotification, object: location)
            }
            // Error
            else {
                // If location services are disabled, then kill the timer and notify about it as it's like a timeout
                if let locationServiceStatus = self?.locationServiceStatus {
                    switch locationServiceStatus {
                    case .Enabled(_):
                        break
                    case .Disabled:
                        self?.invalidateTimer()
                        self?.locationRetrievalTimedOut()
                    }
                }
            }
        }
    }
    
    /**
        Saves my user last known location and an its (optional) place.
    
        :param: place The place linked to that location.
    */
    private func saveMyLastKnownLocationAndPlace(place: Place?) {
        if let location = lastKnownLocation?.location {
            MyUserManager.sharedInstance.saveUserCoordinates(location.coordinate, result: { (result: Result<CLLocationCoordinate2D, SaveUserCoordinatesError>) in }, place: place)
        }
    }
    
    // MARK: > Timer
    
    /**
        Invalidates the location retrieval timer.
    */
    private func invalidateTimer() {
        if gpsLocationRetrievalTimeoutTimer != nil {
            gpsLocationRetrievalTimeoutTimer!.invalidate()
            gpsLocationRetrievalTimeoutTimer = nil
        }
    }
    
    /**
        Restarts the location retrieval timeout timer.
    */
    private func restartTimer() {
        invalidateTimer()
        gpsLocationRetrievalTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(LGCoreKitConstants.locationRetrievalTimeout, target: self, selector: Selector("locationRetrievalTimedOut"), userInfo: nil, repeats: false)
    }
    
    /**
        Called when a location retrieval times out.
    */
    @objc private func locationRetrievalTimedOut() {
        locationRetrievalDidTimeOut = true
        
        // If we haven't received a location, notify about it
        if lastKnownLocation == nil {
            NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.didTimeOutRetrievingLocation, object: nil)
        }
    }
    
    // MARK: > NSNotificationCenter
    
    /**
        Called when the application goes to background.
    
        :param: notification The notification that arised this method.
    */
    @objc private func applicationDidEnterBackground(notification: NSNotification) {
        // Kill the timer
        if gpsLocationRetrievalTimeoutTimer != nil {
            gpsLocationRetrievalTimeoutTimer!.invalidate()
            gpsLocationRetrievalTimeoutTimer = nil
        }
    }
    
    /**
        Called when the application comes from background.
    
        :param: notification The notification that arised this method.
    */
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        // If authorized or disabled, then restart the timer
        switch locationServiceStatus {
        case .Enabled(let authStatus):
            switch authStatus {
            case .Authorized:
                restartTimer()
            case .NotDetermined, .Restricted, .Denied:
                break
            }
        case .Disabled:
            restartTimer()
        }
    }
}

