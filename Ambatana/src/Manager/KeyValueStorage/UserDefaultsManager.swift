//
//  UserDefaultsManager.swift
//  LetGo
//
//  Created by Dídac on 13/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import LGCoreKit
import CoreLocation
import SwiftyUserDefaults




class UserDefaultsManager {

    // Singleton
    static let sharedInstance: UserDefaultsManager = UserDefaultsManager()

//    // Constant
//    private static let bgSuccessfullyKey = "bgSuccessfully"
//    private static let appCrashedKey = "appCrashed"
//    private static let isApproximateLocationKey = "isApproximateLocation"
//    private static let alreadyRatedKey = "alreadyRated"
//    private static let remindMeLaterKey = "remindMeLater"
//
//    private static let alreadySharedKey = "alreadyShared"
//    private static let chatSafetyTipsShown = "chatSafetyTipsShown"
//    private static let lastAppVersionKey = "lastAppVersion"
//    private static let didShowOnboarding = "didShowOnboarding"
//    private static let didShowProductDetailOnboarding = "didShowProductDetailOnboarding"
//    private static let didShowProductDetailOnboardingOthersProduct = "didShowProductDetailOnboardingOthersProduct"
//    private static let didAskForPushPermissionsAtList = "didAskForPushPermissionsAtList"
//    private static let didAskForPushPermissionsDaily = "didAskForPushPermissionsDaily"
//    private static let dailyPermissionDate = "dailyPermissionDate"
//    private static let dailyPermissionAskTomorrow = "dailyPermissionAskTomorrow"
//    private static let shouldShowDirectAnswersKey = "shouldShowDirectAnswersKey_"
//    private static let didShowDirectChatAlert = "didShowDirectChatAlert"
//    private static let didShowCommercializer = "didShowCommercializer"
//    private static let didShowNativePushPermissionsDialog = "didShowNativePushPermissionsDialog"
//    private static let lastGalleryAlbumSelected = "lastGalleryAlbumSelected"
//    private static let lastPostProductTabSelected = "lastPostProductTabSelected"
//    private static let pendingCommercializers = "pendingCommercializers"
//    private static let isGod = "isGod"
//    private static let firstOpenDate = "firstOpenDate"

    private let userDefaults: NSUserDefaults
    private let myUserRepository: MyUserRepository

    private var ownerUserId : String? {
        return myUserRepository.myUser?.objectId
    }


    // MARK: - Lifecycle

    init(userDefaults: NSUserDefaults, myUserRepository: MyUserRepository) {
        self.userDefaults = userDefaults
        self.myUserRepository = myUserRepository
    }

    convenience init() {
        let myUserRepository = Core.myUserRepository
        let userDefaults = NSUserDefaults()
        self.init(userDefaults: userDefaults, myUserRepository: myUserRepository)
    }


    // MARK: - Methods

    /**
    Deletes all user default values
    */
    func resetUserDefaults() {
        guard let userId = ownerUserId else { return }
        resetUserDefaultsForUser(userId)
    }

    /**
    Deletes user default values for a user
    */
    func resetUserDefaultsForUser(userId: String) {
        userDefaults.removeObjectForKey(userId)
        userDefaults.synchronize()
    }

    /**
    Saves if the user wants to use approximate location

    - parameter isApproximateLocation: true if the user wants to use approx location, false if wants to use
    accurate location
    */
    func saveIsApproximateLocation(isApproximateLocation: Bool) {
        guard let userId = ownerUserId else { return }
        saveIsApproximateLocation(isApproximateLocation, forUserId: userId)
    }

    /**
    Loads if the user wants to use approximate location

    :return: if the user wants to use approximate location
    */
    func loadIsApproximateLocation() -> Bool {
        guard let userId = ownerUserId else { return true }
        return loadIsApproximateLocationForUser(userId)
    }

    /**
    Saves if the user rated the app

    - parameter alreadyRated: true if the user rated the app
    */
    func saveAlreadyRated(alreadyRated: Bool) {
        guard let userId = ownerUserId else { return }
        saveAlreadyRated(alreadyRated, forUserId: userId)
    }

    /**
    Loads if the user already ratted the app

    :return: if the user already ratted the app
    */
    func loadAlreadyRated() -> Bool {
        guard let userId = ownerUserId else { return false }
        return loadAlreadyRatedForUser(userId)
    }


    /**
    Saves if the user shared the app

    - parameter alreadyShared: true if the user shared the app
    */
    func saveAlreadyShared(alreadyShared: Bool) {
        guard let userId = ownerUserId else { return }
        saveAlreadyShared(alreadyShared, forUserId: userId)
    }

    /**
    Loads if the user already shared the app

    :return: if the user already shared the app
    */
    func loadAlreadyShared() -> Bool {
        guard let userId = ownerUserId else { return false }
        return loadAlreadySharedForUser(userId)
    }

    /**
     Saves if safety tips popup has been shown for the logged in user

     - parameter shown: true if safety tips has been shown
     */
    func saveChatSafetyTipsShown(shown: Bool) {
        guard let userId = ownerUserId else { return }
        saveChatSafetyTipsShown(shown, forUserId: userId)
    }

    /**
     Loads if the user already got safety tips shown

     :return: if the user already saw safety tips
     */
    func loadChatSafetyTipsShown() -> Bool {
        guard let userId = ownerUserId else { return false }
        return loadChatSafetyTipsShownForUser(userId)
    }

    /**
     Saves if the app went to background successfully

     - parameter bgSuccessfully: true if the app went to background successfully, false while the app is in foreground
     */
    func saveBackgroundSuccessfully(bgSuccessfully: Bool) {
        userDefaults.setObject(NSNumber(bool: bgSuccessfully), forKey: UserDefaultsManager.bgSuccessfullyKey)
    }

    /**
     Loads if the app went to background successfully
     */
    func loadBackgroundSuccessfully() -> Bool {
        let bgSuccessfully = userDefaults.objectForKey(UserDefaultsManager.bgSuccessfullyKey) as? NSNumber
        return bgSuccessfully?.boolValue ?? true
    }

    /**
     Saves if the app crashed previously
     */
    func saveAppCrashed() {
        userDefaults.setObject(NSNumber(bool: true), forKey: UserDefaultsManager.appCrashedKey)
    }

    /**
     Loads if the app crashed
     */
    func loadAppCrashed() -> Bool {
        let appCrashed = userDefaults.objectForKey(UserDefaultsManager.appCrashedKey) as? NSNumber
        return appCrashed?.boolValue ?? false
    }

    /**
     Deletes if the app crashed
     */
    func deleteAppCrashed() {
        userDefaults.removeObjectForKey(UserDefaultsManager.appCrashedKey)
    }

    /**
    Saves the last app version saved in user defaults.
    */
    func saveLastAppVersion(appVersion: AppVersion) {
        guard let lastAppVersion = appVersion.version else {
            return
        }
        userDefaults.setObject(lastAppVersion, forKey: UserDefaultsManager.lastAppVersionKey)
    }

    /**
    Loads the last app version saved in user defaults.

    :return: the last last app version saved in user defaults.
    */
    func loadLastAppVersion() -> String? {
        guard let keyExists = userDefaults.objectForKey(UserDefaultsManager.lastAppVersionKey) as? String else {
            return nil
        }
        return keyExists
    }

    /**
     Saves the date when the user taped remind me later to the rating.
     */
    func saveRemindMeLaterDate() {
        guard let userId = ownerUserId else { return }
        saveRemindMeLaterDateForUserId(userId)
    }

    /**
     Loads the date when the user taped remind me later to the rating
     - returns: The date when the user taped remind me later to the rating
     */
    func loadRemindMeLaterDate() -> NSDate? {
        guard let userId = ownerUserId else { return nil }
        return loadRemindMeLaterDateForUserId(userId)
    }

    /**
     Deletes the date when the user taped remind me later to the rating
     */
    func deleteRemindMeLaterDate() {
        guard let userId = ownerUserId else { return }
        deleteRemindMeLaterDateForUserId(userId)
    }

    /**
    Saves that the onboarding was shown.
    */
    func saveDidShowOnboarding() {
        userDefaults.setObject(NSNumber(bool: true), forKey: UserDefaultsManager.didShowOnboarding)
    }

    /**
    Loads if the onboarding was shown.

    - returns: if the onboarding was shown.
    */
    func loadDidShowOnboarding() -> Bool {
        let didShowOnboarding = userDefaults.objectForKey(UserDefaultsManager.didShowOnboarding) as? NSNumber
        return didShowOnboarding?.boolValue ?? false
    }

    /**
     Saves that the product detail onboarding was shown.
     */
    func saveDidShowProductDetailOnboarding() {
        userDefaults.setObject(NSNumber(bool: true), forKey: UserDefaultsManager.didShowProductDetailOnboarding)
    }

    /**
     Loads if the product detail onboarding was shown.

     - returns: if the product detail onboarding was shown.
     */
    func loadDidShowProductDetailOnboarding() -> Bool {
        let didShowProductDetailOnboarding = userDefaults.objectForKey(UserDefaultsManager.didShowProductDetailOnboarding) as? NSNumber
        return didShowProductDetailOnboarding?.boolValue ?? false
    }

    /**
     Saves that the product detail onboarding last page was shown.
     */
    func saveDidShowProductDetailOnboardingOthersProduct() {
        userDefaults.setObject(NSNumber(bool: true), forKey: UserDefaultsManager.didShowProductDetailOnboardingOthersProduct)
    }

    /**
     Loads if the product detail onboarding last page was shown.

     - returns: if the product detail onboarding last page was shown.
     */
    func loadDidShowProductDetailOnboardingOthersProduct() -> Bool {
        let didShowProductDetailOnboardingOthersProduct = userDefaults.objectForKey(UserDefaultsManager.didShowProductDetailOnboardingOthersProduct) as? NSNumber
        return didShowProductDetailOnboardingOthersProduct?.boolValue ?? false
    }

    /**
    Saves that the pre permisson alert for push notifications was shown in the products list.
    */
    func saveDidAskForPushPermissionsAtList() {
        userDefaults.setObject(NSNumber(bool: true), forKey: UserDefaultsManager.didAskForPushPermissionsAtList)
    }

    /**
    Loads if the pre permisson alert for push notifications was shown in the products list.

    - returns: if the pre permisson alert for push notifications was shown.
    */
    func loadDidAskForPushPermissionsAtList() -> Bool {
        let didAskForPushPermissionsAtList = userDefaults.objectForKey(UserDefaultsManager.didAskForPushPermissionsAtList)
            as? NSNumber
        return didAskForPushPermissionsAtList?.boolValue ?? false
    }

    /**
    Saves that the pre permisson alert for push notifications was shown in chats or sell.

    - parameter askTomorrow: true if user should be asked the day after
    */
    func saveDidAskForPushPermissionsDaily(askTomorrow askTomorrow: Bool) {
        let dailyPermission = [UserDefaultsManager.dailyPermissionDate: NSDate(),
            UserDefaultsManager.dailyPermissionAskTomorrow: askTomorrow]
        userDefaults.setObject(dailyPermission, forKey: UserDefaultsManager.didAskForPushPermissionsDaily)
    }

    /**
    Loads if the pre permisson alert for push notifications was shown in chats or sell.

    - returns: The date the permision was shown
    */
    func loadDidAskForPushPermissionsDailyDate() -> NSDate? {
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
    func loadDidAskForPushPermissionsDailyAskTomorrow() -> Bool? {
        guard let dictPermissionsDaily = loadDidAskForPushPermissionsDaily() else { return nil }
        guard let askTomorrow = dictPermissionsDaily[UserDefaultsManager.dailyPermissionAskTomorrow] as? Bool else {
            return nil
        }
        return askTomorrow
    }

    func loadShouldShowDirectAnswers(subKey: String) -> Bool {
        guard let userId = ownerUserId else { return false }
        return loadShouldShowDirectAnswers(subKey, forUserId: userId)
    }

    func saveShouldShowDirectAnswers(show: Bool, subKey: String) {
        guard let userId = ownerUserId else { return }
        saveShouldShowDirectAnswers(show, subKey: subKey, forUserId: userId)
    }
    
    /**
     Saves that the native push permissions dialog was shown.
     */
    func saveDidShowNativePushPermissionsDialog() {
        userDefaults.setObject(NSNumber(bool: true), forKey: UserDefaultsManager.didShowNativePushPermissionsDialog)
    }
    
    /**
     Loads if the native push permissions dialog was shown.
     
     - returns: if the native push permissions dialog was shown.
     */
    func loadDidShowNativePushPermissionsDialog() -> Bool {
        let key = UserDefaultsManager.didShowNativePushPermissionsDialog
        let didShowNativePushPermissionsDialo = userDefaults.objectForKey(key) as? NSNumber
        return didShowNativePushPermissionsDialo?.boolValue ?? false
    }

    /**
     Saves that the direct chat alert was shown.
     */
    func saveDidShowDirectChatAlert() {
        userDefaults.setObject(NSNumber(bool: true), forKey: UserDefaultsManager.didShowDirectChatAlert)
    }

    /**
     Loads if the direct chat alert was shown.

     - returns: if the direct chat alert was shown.
     */
    func loadDidShowDirectChatAlert() -> Bool {
        let didShowDirectChatAlert = userDefaults.objectForKey(UserDefaultsManager.didShowDirectChatAlert) as? NSNumber
        return didShowDirectChatAlert?.boolValue ?? false
    }

    /**
     Saves that the commercializer was shown.
     */
    func saveDidShowCommercializer() {
        userDefaults.setObject(NSNumber(bool: true), forKey: UserDefaultsManager.didShowCommercializer)
    }

    /**
     Loads if the commercializer was shown.

     - returns: if the commercializer was shown.
     */
    func loadDidShowCommercializer() -> Bool {
        let didShowCommercializer = userDefaults.objectForKey(UserDefaultsManager.didShowCommercializer) as? NSNumber
        return didShowCommercializer?.boolValue ?? false
    }

    /**
     Saves the last tab selected when posting
     */
    func saveLastPostProductTabSelected(tab: Int) {
        userDefaults.setInteger(tab, forKey: UserDefaultsManager.lastPostProductTabSelected)
    }

    /**
     Loads the last tab selected when posting
     */
    func loadLastPostProductTabSelected() -> Int {
        return userDefaults.integerForKey(UserDefaultsManager.lastPostProductTabSelected)
    }

    /**
     Saves the last gallery the user selected when posting
     */
    func saveLastGalleryAlbumSelected(album: String) {
        userDefaults.setObject(album, forKey: UserDefaultsManager.lastGalleryAlbumSelected)
    }

    /**
     Loads the last gallery the user selected when posting
     */
    func loadLastGalleryAlbumSelected() -> String? {
        return userDefaults.objectForKey(UserDefaultsManager.lastGalleryAlbumSelected) as? String
    }

    /**
     Loads the pending commercializers for the logged user
     */
    func loadPendingCommercializers() -> [String:[String]]? {
        guard let userId = ownerUserId else { return nil }
        return loadPendingCommercializers(forUserId: userId)
    }

    /**
     Saves the pending commercializers for the logged user
     */
    func savePendingCommercializers(pending: [String:[String]]) {
        guard let userId = ownerUserId else { return }
        savePendingCommercializers(pending, forUserId: userId)
    }

    /**
     Saves that the current user is God
     */
    func saveIsGod() {
        userDefaults.setObject(NSNumber(bool: true), forKey: UserDefaultsManager.isGod)
    }
    
    /**
     Loads wether the current user is God or not
     */
    func loadIsGod() -> Bool {
        let isGod = userDefaults.objectForKey(UserDefaultsManager.isGod) as? NSNumber
        return isGod?.boolValue ?? false
    }
    
    /**
     Saves that the pre permisson alert for push notifications was shown in chats or sell.
     
     - parameter askTomorrow: true if user should be asked the day after
     */
    func saveFirstOpenDate() {
        userDefaults.setObject(NSDate(), forKey: UserDefaultsManager.firstOpenDate)
    }
    
    /**
     Loads if the pre permisson alert for push notifications was shown in chats or sell.
     
     - returns: The date the permision was shown
     */
    func loadFirstOpenDate() -> NSDate? {
        return userDefaults.objectForKey(UserDefaultsManager.firstOpenDate) as? NSDate
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

    private func saveRemindMeLaterDateForUserId(userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId)
        userDict.setValue(NSDate(), forKey: UserDefaultsManager.remindMeLaterKey)
        userDefaults.setObject(userDict, forKey: userId)
    }

    private func loadRemindMeLaterDateForUserId(userId: String) -> NSDate? {
        let userDict = loadDefaultsDictionaryForUser(userId)
        guard let remindMeLaterSavedDate = userDict.objectForKey(UserDefaultsManager.remindMeLaterKey) as? NSDate else {
            return nil
        }
        return remindMeLaterSavedDate
    }

    private func deleteRemindMeLaterDateForUserId(userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId)
        userDict.removeObjectForKey(UserDefaultsManager.remindMeLaterKey)
        userDefaults.setObject(userDict, forKey: userId)
    }

    private func saveChatSafetyTipsShown(shown: Bool, forUserId userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId)
        userDict.setValue(shown, forKey: UserDefaultsManager.chatSafetyTipsShown)
        userDefaults.setObject(userDict, forKey: userId)
    }

    private func loadChatSafetyTipsShownForUser(userId: String) -> Bool {
        let userDict = loadDefaultsDictionaryForUser(userId)
        guard let keyExists = userDict.objectForKey(UserDefaultsManager.chatSafetyTipsShown) as? Bool else {
            return false
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

    private func loadPendingCommercializers(forUserId userId: String) -> [String:[String]]? {
        let userDict = loadDefaultsDictionaryForUser(userId)
        guard let pending = userDict.objectForKey(UserDefaultsManager.pendingCommercializers) as? [String:[String]]
            else { return nil }
        return pending
    }

    private func savePendingCommercializers(pending: [String:[String]], forUserId userId: String) {
        let userDict = loadDefaultsDictionaryForUser(userId)
        userDict.setValue(pending, forKey: UserDefaultsManager.pendingCommercializers)
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
