//
//  UserDefaultsManager.swift
//  LGCoreKit
//
//  Created by Dídac on 13/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import CoreLocation

/**
Helper for `NSUserDefaults` handling. Currently with this structure:
    userIdValue: {
        alreadyRated:               XX
        chatSafetyTipsLastPageSeen: XX
    }
    didShowOnboarding:  XX
    didAskForPushPermissionsAtList: XX
    didAskForPushPermissionsDaily: {
        dailyPermissionDate: XX-XX-XXXX
        dailyPermissionAskTomorrow: XX
    }
*/
public class UserDefaultsManager {

    // Constant
    private static let isApproximateLocationKey = "isApproximateLocation"
    private static let alreadyRatedKey = "alreadyRated"
    private static let chatSafetyTipsLastPageSeen = "chatSafetyTipsLastPageSeen"
    private static let lastAppVersionKey = "lastAppVersion"
    private static let didShowOnboarding = "didShowOnboarding"
    private static let didAskForPushPermissionsAtList = "didAskForPushPermissionsAtList"
    private static let didAskForPushPermissionsDaily = "didAskForPushPermissionsDaily"
    public static let dailyPermissionDate = "dailyPermissionDate"
    public static let dailyPermissionAskTomorrow = "dailyPermissionAskTomorrow"
    

    public static let sharedInstance: UserDefaultsManager = UserDefaultsManager()

    private let userDefaults: NSUserDefaults

    private var ownerUserId : String? {
        return MyUserRepository.sharedInstance.myUser?.objectId
    }

    // MARK: - Lifecycle

    public init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
    }

    public convenience init() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.init(userDefaults: userDefaults)
    }


    // MARK: - Public Methods

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
    Saves if the user wants to use approximate location

    - parameter isApproximateLocation: true if the user wants to use approx location, false if wants to use
    accurate location
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

    /**
    Saves that the pre permisson alert for push notifications was shown in the products list.
    */
    public func saveDidAskForPushPermissionsAtList() {
        userDefaults.setObject(NSNumber(bool: true), forKey: UserDefaultsManager.didAskForPushPermissionsAtList)
    }

    /**
    Loads if the pre permisson alert for push notifications was shown in the products list.

    - returns: if the pre permisson alert for push notifications was shown.
    */
    public func loadDidAskForPushPermissionsAtList() -> Bool {
        let didAskForPushPermissionsAtList = userDefaults.objectForKey(UserDefaultsManager.didAskForPushPermissionsAtList)
            as? NSNumber
        return didAskForPushPermissionsAtList?.boolValue ?? false
    }

    /**
    Saves that the pre permisson alert for push notifications was shown in chats or sell.

    - parameter askTomorrow: true if user should be asked the day after
    */
    public func saveDidAskForPushPermissionsDaily(askTomorrow askTomorrow: Bool) {
        let dailyPermission = [UserDefaultsManager.dailyPermissionDate: NSDate(),
            UserDefaultsManager.dailyPermissionAskTomorrow: askTomorrow]
        userDefaults.setObject(dailyPermission, forKey: UserDefaultsManager.didAskForPushPermissionsDaily)
    }

    /**
    Loads if the pre permisson alert for push notifications was shown in chats or sell.

    - returns: The date the permision was shown & if should be shown again
    */
    public func loadDidAskForPushPermissionsDaily() -> NSDictionary? {
        let didAskForPushPermissionsDaily = userDefaults.objectForKey(UserDefaultsManager.didAskForPushPermissionsDaily)
            as? NSDictionary
        return didAskForPushPermissionsDaily
    }
}