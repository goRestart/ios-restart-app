//
//  UserDefaultsManager.swift
//  LetGo
//
//  Created by Dídac on 13/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import LGCoreKit
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

    // Singleton
    public static let sharedInstance: UserDefaultsManager = UserDefaultsManager()

    // Constant
    private static let isApproximateLocationKey = "isApproximateLocation"
    private static let alreadyRatedKey = "alreadyRated"
    private static let alreadySharedKey = "alreadyShared"
    private static let chatSafetyTipsLastPageSeen = "chatSafetyTipsLastPageSeen"
    private static let lastAppVersionKey = "lastAppVersion"
    private static let didShowOnboarding = "didShowOnboarding"
    private static let didAskForPushPermissionsAtList = "didAskForPushPermissionsAtList"
    private static let didAskForPushPermissionsDaily = "didAskForPushPermissionsDaily"
    private static let dailyPermissionDate = "dailyPermissionDate"
    private static let dailyPermissionAskTomorrow = "dailyPermissionAskTomorrow"
    private static let shouldShowDirectAnswersKey = "shouldShowDirectAnswersKey_"
    private static let didShowNativePushPermissionsDialog = "didShowNativePushPermissionsDialog"
    private static let lastGalleryAlbumSelected = "lastGalleryAlbumSelected"
    private static let lastPostProductTabSelected = "lastPostProductTabSelected"

    private let userDefaults: NSUserDefaults
    private let myUserRepository: MyUserRepository

    private var ownerUserId : String? {
        return myUserRepository.myUser?.objectId
    }


    // MARK: - Lifecycle

    public init(userDefaults: NSUserDefaults, myUserRepository: MyUserRepository) {
        self.userDefaults = userDefaults
        self.myUserRepository = myUserRepository
    }

    public convenience init() {
        let myUserRepository = Core.myUserRepository
        let userDefaults = NSUserDefaults()
        self.init(userDefaults: userDefaults, myUserRepository: myUserRepository)
    }


    // MARK: - Public Methods

    /**
    Deletes all user default values
    */
    public func resetUserDefaults() {
        guard let userId = ownerUserId else { return }
        resetUserDefaultsForUser(userId)
    }

    /**
    Deletes user default values for a user
    */
    public func resetUserDefaultsForUser(userId: String) {
        userDefaults.removeObjectForKey(userId)
        userDefaults.synchronize()
    }

    /**
    Saves if the user wants to use approximate location

    - parameter isApproximateLocation: true if the user wants to use approx location, false if wants to use
    accurate location
    */
    public func saveIsApproximateLocation(isApproximateLocation: Bool) {
        guard let userId = ownerUserId else { return }
        saveIsApproximateLocation(isApproximateLocation, forUserId: userId)
    }

    /**
    Loads if the user wants to use approximate location

    :return: if the user wants to use approximate location
    */
    public func loadIsApproximateLocation() -> Bool {
        guard let userId = ownerUserId else { return true }
        return loadIsApproximateLocationForUser(userId)
    }

    /**
    Saves if the user rated the app

    - parameter alreadyRated: true if the user rated the app
    */
    public func saveAlreadyRated(alreadyRated: Bool) {
        guard let userId = ownerUserId else { return }
        saveAlreadyRated(alreadyRated, forUserId: userId)
    }

    /**
    Loads if the user already ratted the app

    :return: if the user already ratted the app
    */
    public func loadAlreadyRated() -> Bool {
        guard let userId = ownerUserId else { return false }
        return loadAlreadyRatedForUser(userId)
    }

    /**
    Saves if the user shared the app

    - parameter alreadyShared: true if the user shared the app
    */
    public func saveAlreadyShared(alreadyShared: Bool) {
        guard let userId = ownerUserId else { return }
        saveAlreadyShared(alreadyShared, forUserId: userId)
    }

    /**
    Loads if the user already shared the app

    :return: if the user already shared the app
    */
    public func loadAlreadyShared() -> Bool {
        guard let userId = ownerUserId else { return false }
        return loadAlreadySharedForUser(userId)
    }

    /**
    Saves if the last chat safety tips page that the user has seen.

    - parameter alreadyRated: true if the user rated the app
    */
    public func saveChatSafetyTipsLastPageSeen(page: Int) {
        guard let userId = ownerUserId else { return }
        saveChatSafetyTipsLastPageSeen(page, forUserId: userId)
    }

    /**
    Loads the last chat safety tips page that the user did see.

    :return: the last chat safety tips page that the user did see. Return nil, if never displayed the tips.
    */
    public func loadChatSafetyTipsLastPageSeen() -> Int? {
        guard let userId = ownerUserId else { return nil }
        return loadChatSafetyTipsLastPageSeenForUser(userId)
    }

    /**
    Saves the last app version saved in user defaults.
    */
    public func saveLastAppVersion() {
        guard let lastAppVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        userDefaults.setObject(lastAppVersion, forKey: UserDefaultsManager.lastAppVersionKey)
    }


    /**
    Loads the last app version saved in user defaults.

    :return: the last last app version saved in user defaults.
    */
    public func loadLastAppVersion() -> String? {
        guard let keyExists = userDefaults.objectForKey(UserDefaultsManager.lastAppVersionKey) as? String else {
            return nil
        }
        return keyExists
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

    - returns: The date the permision was shown
    */
    public func loadDidAskForPushPermissionsDailyDate() -> NSDate? {
        guard let dictPermissionsDaily = loadDidAskForPushPermissionsDaily() else { return nil }
        guard let savedDate = dictPermissionsDaily[UserDefaultsManager.dailyPermissionDate] as? NSDate else {
            return nil
        }
        return savedDate
    }

    /**
    Loads if the pre permisson alert for push notifications was shown in chats or sell.

    - returns: if should be shown again
    */
    public func loadDidAskForPushPermissionsDailyAskTomorrow() -> Bool? {
        guard let dictPermissionsDaily = loadDidAskForPushPermissionsDaily() else { return nil }
        guard let askTomorrow = dictPermissionsDaily[UserDefaultsManager.dailyPermissionAskTomorrow] as? Bool else {
            return nil
        }
        return askTomorrow
    }

    public func loadShouldShowDirectAnswers(subKey: String) -> Bool {
        guard let userId = ownerUserId else { return false }
        return loadShouldShowDirectAnswers(subKey, forUserId: userId)
    }

    public func saveShouldShowDirectAnswers(show: Bool, subKey: String) {
        guard let userId = ownerUserId else { return }
        saveShouldShowDirectAnswers(show, subKey: subKey, forUserId: userId)
    }
    
    /**
     Saves that the native push permissions dialog was shown.
     */
    public func saveDidShowNativePushPermissionsDialog() {
        userDefaults.setObject(NSNumber(bool: true), forKey: UserDefaultsManager.didShowNativePushPermissionsDialog)
    }
    
    /**
     Loads if the native push permissions dialog was shown.
     
     - returns: if the native push permissions dialog was shown.
     */
    public func loadDidShowNativePushPermissionsDialog() -> Bool {
        let key = UserDefaultsManager.didShowNativePushPermissionsDialog
        let didShowNativePushPermissionsDialo = userDefaults.objectForKey(key) as? NSNumber
        return didShowNativePushPermissionsDialo?.boolValue ?? false
    }

    /**
     Saves the last tab selected when posting
     */
    public func saveLastPostProductTabSelected(tab: Int) {
        userDefaults.setInteger(tab, forKey: UserDefaultsManager.lastPostProductTabSelected)
    }

    /**
     Loads the last tab selected when posting
     */
    public func loadLastPostProductTabSelected() -> Int {
        return userDefaults.integerForKey(UserDefaultsManager.lastPostProductTabSelected)
    }

    /**
     Saves the last gallery the user selected when posting
     */
    public func saveLastGalleryAlbumSelected(album: String) {
        userDefaults.setObject(album, forKey: UserDefaultsManager.lastGalleryAlbumSelected)
    }

    /**
     Loads the last gallery the user selected when posting
     */
    public func loadLastGalleryAlbumSelected() -> String? {
        return userDefaults.objectForKey(UserDefaultsManager.lastGalleryAlbumSelected) as? String
    }

    // MARK: - Private methods

    /**
    Loads all the current defaults of a user
    - parameter userId: theID of the user owner of the defaults
    */
    private func loadDefaultsDictionaryForUser(userId: String) ->  NSMutableDictionary {
        guard let defaults = userDefaults.objectForKey(userId) as? NSDictionary else { return NSMutableDictionary() }
        return NSMutableDictionary(dictionary: defaults)
    }

    private func saveIsApproximateLocation(isApproximateLocation: Bool, forUserId userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId)
        userDict.setValue(isApproximateLocation, forKey: UserDefaultsManager.isApproximateLocationKey)
        userDefaults.setObject(userDict, forKey: userId)
    }

    private func loadIsApproximateLocationForUser(userId: String) -> Bool {
        let userDict = loadDefaultsDictionaryForUser(userId)
        guard let keyExists = userDict.objectForKey(UserDefaultsManager.isApproximateLocationKey) as? Bool else {
            return true
        }
        return keyExists
    }

    private func saveAlreadyShared(alreadyShared: Bool, forUserId userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId)
        userDict.setValue(alreadyShared, forKey: UserDefaultsManager.alreadySharedKey)
        userDefaults.setObject(userDict, forKey: userId)
    }

    private func loadAlreadySharedForUser(userId: String) -> Bool {
        let userDict = loadDefaultsDictionaryForUser(userId)
        guard let keyExists = userDict.objectForKey(UserDefaultsManager.alreadySharedKey) as? Bool else {
            return false
        }
        return keyExists
    }

    private func saveAlreadyRated(alreadyRated: Bool, forUserId userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId)
        userDict.setValue(alreadyRated, forKey: UserDefaultsManager.alreadyRatedKey)
        userDefaults.setObject(userDict, forKey: userId)
    }

    private func loadAlreadyRatedForUser(userId: String) -> Bool {
        let userDict = loadDefaultsDictionaryForUser(userId)
        guard let keyExists = userDict.objectForKey(UserDefaultsManager.alreadyRatedKey) as? Bool else {
            return false
        }
        return keyExists
    }

    private func saveChatSafetyTipsLastPageSeen(page: Int, forUserId userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId)
        userDict.setValue(page, forKey: UserDefaultsManager.chatSafetyTipsLastPageSeen)
        userDefaults.setObject(userDict, forKey: userId)
    }

    private func loadChatSafetyTipsLastPageSeenForUser(userId: String) -> Int? {
        let userDict = loadDefaultsDictionaryForUser(userId)
        guard let keyExists = userDict.objectForKey(UserDefaultsManager.chatSafetyTipsLastPageSeen) as? Int else {
            return nil
        }
        return keyExists
    }

    private func loadShouldShowDirectAnswers(subKey: String, forUserId userId: String) -> Bool {
        let userDict = loadDefaultsDictionaryForUser(userId)
        guard let keyExists = userDict.objectForKey(UserDefaultsManager.shouldShowDirectAnswersKey+subKey) as? Bool else {
            return true
        }
        return keyExists
    }

    private func saveShouldShowDirectAnswers(show: Bool, subKey: String, forUserId userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId)
        userDict.setValue(show, forKey: UserDefaultsManager.shouldShowDirectAnswersKey+subKey)
        userDefaults.setObject(userDict, forKey: userId)
    }


    /**
    Loads if the pre permisson alert for push notifications was shown in chats or sell.

    - returns: The date the permision was shown & if should be shown again
    */
    private func loadDidAskForPushPermissionsDaily() -> NSDictionary? {
        let didAskForPushPermissionsDaily = userDefaults.objectForKey(UserDefaultsManager.didAskForPushPermissionsDaily)
            as? NSDictionary
        return didAskForPushPermissionsDaily
    }
}
