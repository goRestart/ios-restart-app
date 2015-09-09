//
//  UserDefaultsManager.swift
//  LGCoreKit
//
//  Created by Dídac on 13/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import CoreLocation

public class UserDefaultsManager {
    
    // Constant
    private static let latitudeKey = "latitude"
    private static let longitudeKey = "longitude"
    private static let manualLocationKey = "manualLocation"
    private static let isManualLocationKey = "isManualLocation"
    private static let isApproximateLocationKey = "isApproximateLocation"
    private static let alreadyRatedKey = "alreadyRated"

    private let keysArray = [latitudeKey, longitudeKey, manualLocationKey, isManualLocationKey, isApproximateLocationKey, alreadyRatedKey]
    
    public static let sharedInstance: UserDefaultsManager = UserDefaultsManager()
    
    private var userDefaults: NSUserDefaults
    
    
    // MARK: - Lifecycle
    
    init(userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        self.userDefaults = userDefaults
    }
    

    // MARK: - Public Methods

    
    /**
        Deletes all user default values
    */
    
    public func resetUserDefaults() {
        
        for key in keysArray {
            userDefaults.removeObjectForKey(key)
        }
        userDefaults.synchronize()
    }
    
    
    /**
        Saves the location set manually by the user

        :param: location the manual location set by the user
    */
    
    public func saveManualLocation(location: CLLocation) {
        
        var locationDict = [UserDefaultsManager.latitudeKey : location.coordinate.latitude,
                            UserDefaultsManager.longitudeKey : location.coordinate.longitude]
        
        userDefaults.setObject(locationDict, forKey: UserDefaultsManager.manualLocationKey)
    }
    
    /**
        Loads the location set manually by the user
    
        :return: last manual location saved by the user
    */
    
    public func loadManualLocation() -> CLLocation? {
        
        if let locationDict = userDefaults.objectForKey(UserDefaultsManager.manualLocationKey) as? NSDictionary {
            var lat = locationDict[UserDefaultsManager.latitudeKey] as! CLLocationDegrees
            var long = locationDict[UserDefaultsManager.longitudeKey] as! CLLocationDegrees
            
            var location = CLLocation(latitude: lat, longitude: long)
            
            return location
        }
        return nil
    }

    
    /**
        Saves if the last time the location changed was set manually by the user
    
        :param: isManualLocation true if the user edited manually the location, false if uses GPS location
    */
    
    public func saveIsManualLocation(isManualLocation: Bool) {
        userDefaults.setBool(isManualLocation, forKey: UserDefaultsManager.isManualLocationKey)
    }

    
    /**
        Loads if the last time the location changed was set manually by the user
    
        :return: if the user is using manually set location
    */

    public func loadIsManualLocation() -> Bool {
        
        if let keyExists = userDefaults.objectForKey(UserDefaultsManager.isManualLocationKey) as? Bool {
            return userDefaults.boolForKey(UserDefaultsManager.isManualLocationKey)
        }
        
        return false
    }

    
    /**
        Saves if the user wants to use approximate location
    
        :param: isApproximateLocation true if the user wants to use approx location, false if wants to use accurate location
    */
    
    public func saveIsApproximateLocation(isApproximateLocation: Bool) {
        userDefaults.setBool(isApproximateLocation, forKey: UserDefaultsManager.isApproximateLocationKey)
    }
    
    
    /**
        Loads if the user wants to use approximate location
    
        :return: if the user wants to use approximate location
    */

    public func loadIsApproximateLocation() -> Bool {
        
        if let keyExists = userDefaults.objectForKey(UserDefaultsManager.isApproximateLocationKey) as? Bool {
            return userDefaults.boolForKey(UserDefaultsManager.isApproximateLocationKey)
        }
        
        return true
    }
    
    /**
        Saves if the user rated the app
    
        :param: alreadyRated true if the user rated the app
    */
    
    public func saveAlreadyRated(alreadyRated: Bool) {
        userDefaults.setBool(alreadyRated, forKey: UserDefaultsManager.alreadyRatedKey)
    }
    
    
    /**
        Loads if the user already ratted the app
    
        :return: if the user already ratted the app
    */
    
    public func loadAlreadyRated() -> Bool {
        
        if let keyExists = userDefaults.objectForKey(UserDefaultsManager.alreadyRatedKey) as? Bool {
            return userDefaults.boolForKey(UserDefaultsManager.alreadyRatedKey)
        }
        
        return false
    }
    
}