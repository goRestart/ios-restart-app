//
//  LocationManager.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 06/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import AddressBookUI

private let kAmbatanaLocationTimerUpdateInterval: NSTimeInterval = 300
private let kAmbatanaUserWantsToSpecifyLocationDirectly = "AmbatanaUserWantsToSpecifyLocationDirectly"

// private singleton instance
private let _singletonInstance = LocationManager()

/**
* The LocationManager is in charge of handling the position of the user, updating it conveniently when the user has changed it significantly.
* LocationManager follows the Singleton pattern, so it's accessed by means of the shared method sharedInstance().
*/
class LocationManager: NSObject, CLLocationManagerDelegate {
    // vars & data
    var clLocationManager = CLLocationManager()
    var authorizationStatus: CLAuthorizationStatus = .NotDetermined
    var lastKnownLocation: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid {
        didSet {
            updatingLocation = false
            evaluateChangeInUserPosition()
        }
    }
    var lastRegisteredLocation: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var locationTimer: NSTimer!
    let geocoder = CLGeocoder()
    var updatingLocation = false
    
    /** Shared instance */
    class var sharedInstance: LocationManager {
        return _singletonInstance
    }
    
    /** Initialization */
    override init() {
        super.init()
        clLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        clLocationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            if iOSVersionAtLeast("8.0") {
                clLocationManager.requestWhenInUseAuthorization()
            } else {
                self.startUpdatingLocation()
            }
        }
    }
    
    func logOutUser() {
        lastKnownLocation = kCLLocationCoordinate2DInvalid
        lastRegisteredLocation = kCLLocationCoordinate2DInvalid
    }
    
    /** Terminates the location manager, flushing all resources and stopping all timers. */
    func terminate() {
        locationTimer?.invalidate()
        locationTimer = nil
        self.updatingLocation = false
        clLocationManager.stopUpdatingLocation()
    }
    
    // MARK: - Location methods
    
    func startUpdatingLocation() {
        self.clLocationManager.startUpdatingLocation()
        self.updatingLocation = true
        if locationTimer == nil { // clear previous timer
            locationTimer = NSTimer.scheduledTimerWithTimeInterval(kAmbatanaLocationTimerUpdateInterval, target: self, selector: "updateLocationTimerTriggered", userInfo: nil, repeats: true)
        }
    }
    
    /** This function is called by the locationTimer to update the location of the user. It should not be called outside LocationManager. */
    internal func updateLocationTimerTriggered() {
        if (!self.updatingLocation) {
            self.updatingLocation = true
            self.clLocationManager.startUpdatingLocation()
        }
    }
    
    func currentLocation() -> CLLocationCoordinate2D {
        return clLocationManager.location?.coordinate ?? lastKnownLocation
    }
    
    func appIsAuthorizedToUseLocationServices() -> Bool {
        if (authorizationStatus == .Authorized || authorizationStatus == .AuthorizedWhenInUse) { return true }
        else { return false }
    }
    
    private func evaluateChangeInUserPosition() {
        println("Evaluating changes in user position...")
        // sanity check
        if PFUser.currentUser() == nil { return } // we are not logged in yet.
        if (!CLLocationCoordinate2DIsValid(self.lastKnownLocation)) { return } // we don't have a valid location coordinate.
        
        // if we don't have a recorded location, we should try to retrieve it from Parse first.
        if (!CLLocationCoordinate2DIsValid(self.lastRegisteredLocation)) {
            println("Trying to retrieve last registered location...")
            if let registeredLocationObject = PFUser.currentUser()["gpscoords"] as? PFGeoPoint {
                println("Previous information found \(registeredLocationObject)")
                // Create a new local last registered location object
                self.lastRegisteredLocation = CLLocationCoordinate2DMake(registeredLocationObject.latitude, registeredLocationObject.longitude)
            } else { // no previous information, register current position as the valid position and exit
                println("No previous information found")
                self.lastRegisteredLocation = self.lastKnownLocation
                let initialLocation = CLLocation(coordinate: self.lastKnownLocation, altitude: 1, horizontalAccuracy: 1, verticalAccuracy: -1, timestamp: nil)
                updateRegisteredLocation(initialLocation)
                return
            }
        }

        // evaluate distance between coordinates to check if they are more than 1km
        let latestLocation = CLLocation(coordinate: self.lastKnownLocation, altitude: 1, horizontalAccuracy: 1, verticalAccuracy: -1, timestamp: nil)
        let registeredLocation = CLLocation(coordinate: self.lastRegisteredLocation, altitude: 1, horizontalAccuracy: 1, verticalAccuracy: -1, timestamp: nil)
        
        if (latestLocation.distanceFromLocation(registeredLocation) > 1000) { // if new location is more than 1km away from last registered location...
            println("Registering new location: \(latestLocation)")
            updateRegisteredLocation(latestLocation)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(kAmbatanaUserLocationSuccessfullySetNotification, object: latestLocation)
        }
        
    }
    
    func userSpecifiedLocationDirectly(directLocation: CLLocationCoordinate2D, mustNotifyObservers: Bool) {
        self.lastKnownLocation = directLocation
        let latestLocation = CLLocation(coordinate: directLocation, altitude: 1, horizontalAccuracy: 1, verticalAccuracy: -1, timestamp: nil)
        NSUserDefaults.standardUserDefaults().setObject(kAmbatanaUserWantsToSpecifyLocationDirectly, forKey: kAmbatanaUserWantsToSpecifyLocationDirectly)
        updateRegisteredLocation(latestLocation, notifyObservers: mustNotifyObservers)
    }
    
    private func updateRegisteredLocation(latestLocation: CLLocation, notifyObservers: Bool = true) {
        // get the reverse geocoding location of the user from his/her coordinates.
        geocoder.reverseGeocodeLocation(latestLocation, completionHandler: { (placemarks, error) -> Void in
            let geoPoint = PFGeoPoint(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
            PFUser.currentUser()["gpscoords"] = geoPoint
            println("Updating user location to \(latestLocation.description)...")
            
            if placemarks?.count > 0 {
                if let placemark = placemarks?.first as? CLPlacemark {
                    // extract elements and update user.
                    if placemark.locality != nil {
                        PFUser.currentUser()["city"] = placemark.locality
                        ConfigurationManager.sharedInstance.userLocation = placemark.locality
                    }
                    if placemark.ISOcountryCode != nil { PFUser.currentUser()["country_code"] = placemark.ISOcountryCode }
                    if placemark.addressDictionary != nil {
                        let addressString = ABCreateStringWithAddressDictionary(placemark.addressDictionary, false)
                        if addressString != nil { PFUser.currentUser()["address"] = addressString }
                    }
                }
            }
            PFUser.currentUser().saveInBackgroundWithBlock({ (success, error) -> Void in
                if (success) {
                    println("*** Updated registered user location successfully")
                    self.lastRegisteredLocation = latestLocation.coordinate
                    if notifyObservers { NSNotificationCenter.defaultCenter().postNotificationName(kAmbatanaUserLocationSuccessfullyChangedNotification, object: latestLocation) }
                } else {
                    println("*** Error setting registered user's location")
                    if notifyObservers { NSNotificationCenter.defaultCenter().postNotificationName(kAmbatanaUnableToSetUserLocationNotification, object: nil) }
                }
            })
        })
    }
    
    // MARK: - CLLocationManagerDelegate methods
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("Location manager received locations: \(locations)")
        self.updatingLocation = false
        clLocationManager.stopUpdatingLocation()
        if (locations?.count > 0) {
            if let lastLocation = locations.last as? CLLocation {
                // Just for testing purposes. Uncomment to set a specific location in the simulator, normal location on an actual device.
                #if (arch(i386) || arch(x86_64)) && os(iOS) // we are in the simulator.
                    self.lastKnownLocation = CLLocationCoordinate2DMake(40.416947, -3.703528)
                #else
                    self.lastKnownLocation = lastLocation.coordinate
                #endif
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("Location manager status changed to \(status.rawValue)")
        self.authorizationStatus = status
        // check if user is allowed to use location services.
        if appIsAuthorizedToUseLocationServices() { // start updating location
            println("We are authorized, so start updating location!")
            NSUserDefaults.standardUserDefaults().removeObjectForKey(kAmbatanaUserWantsToSpecifyLocationDirectly)
            self.startUpdatingLocation()
        } else { // ask the user to enter his/her location.
            if (PFUser.currentUser() == nil) { return }
            println("We are NOT authorized, falling back to registered location or ask user for its location.")
            // invalidate the timer.
            if (locationTimer != nil) { locationTimer.invalidate() }
            
            // check if the user has explicitly indicated his/her location because can't/doesn't want it to be retrieved from the device.
            let defaults = NSUserDefaults.standardUserDefaults()
            if let directLocation = NSUserDefaults.standardUserDefaults().objectForKey(kAmbatanaUserWantsToSpecifyLocationDirectly) as? String {
                // try to get location for the current user from parse, and use it as the .
                if let registeredLocationObject = PFUser.currentUser()["gpscoords"] as? PFGeoPoint {
                    println("Location retrieved from previously registered entry in backend")
                    // use this registered location as the current location.
                    self.lastRegisteredLocation = CLLocationCoordinate2DMake(registeredLocationObject.latitude, registeredLocationObject.longitude)
                    self.lastKnownLocation = self.lastRegisteredLocation
                } else {
                    println("Unable to get location")
                    NSNotificationCenter.defaultCenter().postNotificationName(kAmbatanaUnableToGetUserLocationNotification, object: nil)
                }
            } else {
                println("Unable to get location")
                NSNotificationCenter.defaultCenter().postNotificationName(kAmbatanaUnableToGetUserLocationNotification, object: nil)
            }
            updatingLocation = false
        }
    }

}







