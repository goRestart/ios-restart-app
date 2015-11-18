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
    private static let chatSafetyTipsLastPageSeen = "chatSafetyTipsLastPageSeen"
    private static let lastAppVersionKey = "lastAppVersion"
    private static let didShowOnboarding = "didShowOnboarding"

    private let keysArray = [latitudeKey, longitudeKey, manualLocationKey, isManualLocationKey, isApproximateLocationKey, alreadyRatedKey, chatSafetyTipsLastPageSeen]
    
    public static let sharedInstance: UserDefaultsManager = UserDefaultsManager()
    
    public private(set) var userDefaults: NSUserDefaults
    
    private var ownerUserId : String? {
        return MyUserManager.sharedInstance.myUser()?.objectId
    }
    
    // MARK: - Lifecycle
    
    init(userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        self.userDefaults = userDefaults
    }
    

    // MARK: - Public Methods

//    userIdValue: {
//        manualLocation: {
//            latitude:   XXXXXX
//            longitude:  XXXXXX
//        }
//        isManualLocation:           XX
//        isApproximateLocation:      XX
//        alreadyRated:               XX
//        chatSafetyTipsLastPageSeen: XX
//    }
//    didShowOnboarding:  XX
    
    /**
        Will be called the 1st time when updating to version 1.4.0
    */
    public func rebuildUserDefaultsForUser() {
    
        if let userId = ownerUserId {
            if loadDefaultsDictionaryForUser(userId).count == 0 {
                
                let itemsDict : NSMutableDictionary = NSMutableDictionary()
                
                if let locationDict = userDefaults.objectForKey(UserDefaultsManager.manualLocationKey) as? NSDictionary {
                    itemsDict.setObject(locationDict, forKey: UserDefaultsManager.manualLocationKey)
                }
                if let isManualLocation = userDefaults.objectForKey(UserDefaultsManager.isManualLocationKey) as? Bool {
                    itemsDict.setValue(isManualLocation, forKey: UserDefaultsManager.isManualLocationKey)
                }
                if let isApproxLocation = userDefaults.objectForKey(UserDefaultsManager.isApproximateLocationKey) as? Bool {
                    itemsDict.setValue(isApproxLocation, forKey: UserDefaultsManager.isApproximateLocationKey)
                }
                if let alreadyRated = userDefaults.objectForKey(UserDefaultsManager.alreadyRatedKey) as? Bool {
                    itemsDict.setValue(alreadyRated, forKey: UserDefaultsManager.alreadyRatedKey)
                }
                if let chatSafetyTipsLastPage = userDefaults.objectForKey(UserDefaultsManager.chatSafetyTipsLastPageSeen) as? Int {
                    itemsDict.setValue(chatSafetyTipsLastPage, forKey: UserDefaultsManager.chatSafetyTipsLastPageSeen)
                }
                
                userDefaults.setObject(itemsDict, forKey: userId)
                
                for key in keysArray {
                    userDefaults.removeObjectForKey(key)
                }
                userDefaults.synchronize()
            }
            
        }
    }
    
    /**
        Deletes all user default values
    */
    public func resetUserDefaults() {
        
        if let userId = ownerUserId {
            resetUserDefaultsForUser(userId)
        }
    }

    /**
        Deletes user default values for a user
    */
    public func resetUserDefaultsForUser(userId: String) {
        userDefaults.removeObjectForKey(userId)
        userDefaults.synchronize()
    }

    /**
        Loads all the current defaults of a user
        - parameter userId: theID of the user owner of the defaults
    */
    public func loadDefaultsDictionaryForUser(userId: String) ->  NSMutableDictionary {
        
        if let defaults = userDefaults.objectForKey(userId) as? NSDictionary {
            let userDict : NSMutableDictionary = NSMutableDictionary(dictionary: defaults)
            return userDict
        }
        return NSMutableDictionary()
    }
    
    /**
        Saves the location set manually by the user

        - parameter location: the manual location set by the user
    */
    public func saveManualLocation(location: CLLocation) {
        
        if let userId = ownerUserId {
            saveManualLocation(location, forUserId: userId)
        }
    }
    
    /**
        Saves the location set manually by the user
    
        - parameter location: the manual location set by the user
        - parameter userId: The ID of the user who sets the location
    */
    public func saveManualLocation(location: CLLocation, forUserId userId: String) {

        let locationDict = [UserDefaultsManager.latitudeKey : location.coordinate.latitude,
                            UserDefaultsManager.longitudeKey : location.coordinate.longitude]

        let userDict = loadDefaultsDictionaryForUser(userId) ?? NSMutableDictionary()
        
        userDict.setValue(locationDict, forKey: UserDefaultsManager.manualLocationKey)
        
        userDefaults.setObject(userDict, forKey: userId)
    }
    
    /**
        Loads the location set manually by the user
    
        :return: last manual location saved by the user
    */
    public func loadManualLocation() -> CLLocation? {
        
        if let userId = ownerUserId {
            return loadManualLocationForUser(userId)
        }
        return nil
    }
    
    public func loadManualLocationForUser(userId: String) -> CLLocation? {
        
        let userDict = loadDefaultsDictionaryForUser(userId)
        if let locationDict = userDict.objectForKey(UserDefaultsManager.manualLocationKey) as? NSDictionary {
            let lat = locationDict[UserDefaultsManager.latitudeKey] as! CLLocationDegrees
            let long = locationDict[UserDefaultsManager.longitudeKey] as! CLLocationDegrees
            
            let location = CLLocation(latitude: lat, longitude: long)
            
            return location
        }
        return nil
    }
    
    /**
        Saves if the last time the location changed was set manually by the user
    
        - parameter isManualLocation: true if the user edited manually the location, false if uses GPS location
    */
    public func saveIsManualLocation(isManualLocation: Bool) {
        if let userId = ownerUserId {
            saveIsManualLocation(isManualLocation, forUserId: userId)
        }
    }

    public func saveIsManualLocation(isManualLocation: Bool, forUserId userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId)
        userDict.setValue(isManualLocation, forKey: UserDefaultsManager.isManualLocationKey)
        userDefaults.setObject(userDict, forKey: userId)
    }


    /**
        Loads if the last time the location changed was set manually by the user
    
        :return: if the user is using manually set location
    */
    public func loadIsManualLocation() -> Bool {
        
        if let userId = ownerUserId {
            return loadIsManualLocationForUser(userId)
        }
        
        return false
    }

    public func loadIsManualLocationForUser(userId: String) -> Bool {
        
        let userDict = loadDefaultsDictionaryForUser(userId)
        if let keyExists = userDict.objectForKey(UserDefaultsManager.isManualLocationKey) as? Bool {
            return keyExists
        }
        return false
    }
    
    /**
        Saves if the user wants to use approximate location
    
        - parameter isApproximateLocation: true if the user wants to use approx location, false if wants to use accurate location
    */
    public func saveIsApproximateLocation(isApproximateLocation: Bool) {
        if let userId = ownerUserId {
            saveIsApproximateLocation(isApproximateLocation, forUserId: userId)
        }
    }
    
    public func saveIsApproximateLocation(isApproximateLocation: Bool, forUserId userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId)
        userDict.setValue(isApproximateLocation, forKey: UserDefaultsManager.isApproximateLocationKey)
        userDefaults.setObject(userDict, forKey: userId)
    }
    
    /**
        Loads if the user wants to use approximate location
    
        :return: if the user wants to use approximate location
    */
    public func loadIsApproximateLocation() -> Bool {
        
        if let userId = ownerUserId {
            return loadIsApproximateLocationForUser(userId)
        }
        return true
    }

    public func loadIsApproximateLocationForUser(userId: String) -> Bool {
        
        let userDict = loadDefaultsDictionaryForUser(userId)
        if let keyExists = userDict.objectForKey(UserDefaultsManager.isApproximateLocationKey) as? Bool {
            return keyExists
        }
        return true
    }

    /**
        Saves if the user rated the app
    
        - parameter alreadyRated: true if the user rated the app
    */
    public func saveAlreadyRated(alreadyRated: Bool) {
        if let userId = ownerUserId {
            saveAlreadyRated(alreadyRated, forUserId: userId)
        }
    }
    
    public func saveAlreadyRated(alreadyRated: Bool, forUserId userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId) ?? NSMutableDictionary()
        userDict.setValue(alreadyRated, forKey: UserDefaultsManager.alreadyRatedKey)
        userDefaults.setObject(userDict, forKey: userId)
    }
    
    /**
        Loads if the user already ratted the app
    
        :return: if the user already ratted the app
    */
    public func loadAlreadyRated() -> Bool {
        
        if let userId = ownerUserId {
            return loadAlreadyRatedForUser(userId)
        }
        return false
    }
    
    public func loadAlreadyRatedForUser(userId: String) -> Bool {
        
        let userDict = loadDefaultsDictionaryForUser(userId)
        if let keyExists = userDict.objectForKey(UserDefaultsManager.alreadyRatedKey) as? Bool {
            return keyExists
        }
        return false
    }
    
    /**
        Saves if the last chat safety tips page that the user has seen.
    
        - parameter alreadyRated: true if the user rated the app
    */
    public func saveChatSafetyTipsLastPageSeen(page: Int) {
        if let userId = ownerUserId {
            saveChatSafetyTipsLastPageSeen(page, forUserId: userId)
        }
    }
    
    public func saveChatSafetyTipsLastPageSeen(page: Int, forUserId userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId) ?? NSMutableDictionary()
        userDict.setValue(page, forKey: UserDefaultsManager.chatSafetyTipsLastPageSeen)
        userDefaults.setObject(userDict, forKey: userId)
    }
    
    /**
        Loads the last chat safety tips page that the user did see.
    
        :return: the last chat safety tips page that the user did see. Return nil, if never displayed the tips.
    */
    public func loadChatSafetyTipsLastPageSeen() -> Int? {
        
        if let userId = ownerUserId {
            return loadChatSafetyTipsLastPageSeenForUser(userId)
        }
        return nil
    }
    
    public func loadChatSafetyTipsLastPageSeenForUser(userId: String) -> Int? {
        let userDict = loadDefaultsDictionaryForUser(userId)
        if let keyExists = userDict.objectForKey(UserDefaultsManager.chatSafetyTipsLastPageSeen) as? Int {
            return keyExists
        }
        return nil
    }
    
    /**
        Saves the last app version saved in user defaults.
    */
    public func saveLastAppVersion() {
        if let lastAppVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            userDefaults.setObject(lastAppVersion, forKey: UserDefaultsManager.lastAppVersionKey)
        }
    }
    
    
    /**
        Loads the last app version saved in user defaults.
    
        :return: the last last app version saved in user defaults.
    */
    public func loadLastAppVersion() -> String? {
        
        if let keyExists = userDefaults.objectForKey(UserDefaultsManager.lastAppVersionKey) as? String {
            return keyExists
        }
        return nil
    }
    
    /**
        Saves that the onboarding was shown.
    */
    public func saveDidShowOnboarding() {
        userDefaults.setObject(NSNumber(bool: true), forKey: UserDefaultsManager.didShowOnboarding)
    }
    
    /**
        Loads if the onboarding was shown.
    
         - returns: if the onboarding was shown.
    */
    public func loadDidShowOnboarding() -> Bool {
        let didShowOnboarding = userDefaults.objectForKey(UserDefaultsManager.didShowOnboarding) as? NSNumber
        return didShowOnboarding?.boolValue ?? false
    }
}