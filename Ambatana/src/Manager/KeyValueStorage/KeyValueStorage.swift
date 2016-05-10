//
//  KeyValueStorage.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import SwiftyUserDefaults

/**
 NSUserDefaults key-value structure:

 <app_key>: <value>
 <app_key>: <value>
 ...
 <user_id>: {
    <user_key>: <value>
    <user_key>: <value>
    ...
 }
 */

// MARK: - App keys

extension DefaultsKeys {
    static let didEnterBackground = DefaultsKey<Bool>("didEnterBackground")
    static let didCrash = DefaultsKey<Bool>("didCrash")

    static let firstRunDate = DefaultsKey<NSDate?>("firstOpenDate")
    static let lastRunAppVersion = DefaultsKey<String?>("lastRunAppVersion")

    static let didShowOnboarding = DefaultsKey<Bool>("didShowOnboarding")
    static let didShowProductDetailOnboarding = DefaultsKey<Bool>("didShowProductDetailOnboarding")
    static let didShowProductDetailOnboardingOthersProduct = DefaultsKey<Bool>("didShowProductDetailOnboardingOthersProduct")

    static let didAskForPushPermissionsAtList = DefaultsKey<Bool>("didAskForPushPermissionsAtList")
    static let didAskForPushPermissionsDaily = DefaultsKey<Bool>("didAskForPushPermissionsDaily")
    static let pushPermissionsDailyDate = DefaultsKey<NSDate>("dailyPermissionDate")

    static let didShowDirectChatAlert = DefaultsKey<Bool>("didShowDirectChatAlert")
    static let didShowCommercializer = DefaultsKey<Bool>("didShowCommercializer")
    static let isGod = DefaultsKey<Bool>("isGod")
}


// MARK: - KeyValueStorage

class KeyValueStorage {
    static let sharedInstance: KeyValueStorage = KeyValueStorage()

    private var storage: KeyValueStorageable
    private let myUserRepository: MyUserRepository


    // MARK: - Lifecycle

    init(storage: KeyValueStorageable, myUserRepository: MyUserRepository) {
        self.storage = storage
        self.myUserRepository = myUserRepository
    }

    convenience init() {
        let myUserRepository = Core.myUserRepository
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.init(storage: userDefaults, myUserRepository: myUserRepository)
    }
}


// MARK: - Public methods

extension KeyValueStorage {
    var userAppShared: Bool {
        get { currentUserProperties?.appShared }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.appShared = newValue
            currentUserProperties = userProperties
        }
    }
    var userLocationApproximate: Bool {
        get { currentUserProperties?.userLocationApproximate }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.userLocationApproximate = newValue
            currentUserProperties = userProperties
        }
    }
    var userChatSafetyTipsShown: Bool {
        get { currentUserProperties?.chatSafetyTipsShown }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.chatSafetyTipsShown = newValue
            currentUserProperties = userProperties
        }
    }
    func userLoadChatShowDirectAnswersForKey(key: String) -> Bool? {
        return currentUserProperties?.chatShowDirectAnswers[key]
    }
    func userSaveChatShowDirectAnswersForKey(key: String, value: Bool?) {
        currentUserProperties?.chatShowDirectAnswers[key] = value
    }
    var userRatingAlreadyRated: Bool {
        get { currentUserProperties?.ratingAlreadyRated }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.ratingAlreadyRated = newValue
            currentUserProperties = userProperties
        }
    }
    var userRatingRemindMeLaterDate: NSDate? {
        get { currentUserProperties?.ratingRemindMeLaterDate }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.ratingRemindMeLaterDate = newValue
            currentUserProperties = userProperties
        }
    }
    var userPostProductLastGalleryAlbumSelected: String? {
        get { currentUserProperties?.ratingRemindMeLaterDate }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.postProductLastGalleryAlbumSelected = newValue
            currentUserProperties = userProperties
        }
    }
    var userPostProductLastTabSelected: Int {
        get { currentUserProperties?.ratingRemindMeLaterDate }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.postProductLastTabSelected = newValue
            currentUserProperties = userProperties
        }
    }
    var userCommercializersPending: [String:[String]] {
        get { currentUserProperties?.commercializersPending }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.commercializersPending = newValue
            currentUserProperties = userProperties
        }
    }
}


// MARK: - Private methods

private extension KeyValueStorage {
    private var currentUserId : String? {
        return myUserRepository.myUser?.objectId
    }
    private var currentUserKey: DefaultsKey<UserDefaultsUser>? {
        guard let currentUserId = currentUserId else { return nil }
        return DefaultsKey<UserDefaultsUser>(currentUserId)
    }
    private var currentUserProperties: UserDefaultsUser? {
        get {
            guard let key = currentUserKey else { return nil }
            return get(key)
        }
        set {
            guard let key = currentUserKey else { return }
            set(key, value: newValue)
        }
    }
}



// MARK: - KeyValueStorageable

extension KeyValueStorage: KeyValueStorageable {
    subscript(key: DefaultsKey<String?>) -> String? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<String>) -> String {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<NSString?>) -> NSString? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<NSString>) -> NSString {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<Int?>) -> Int? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<Int>) -> Int {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<Double?>) -> Double? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<Double>) -> Double {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<Bool?>) -> Bool? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<Bool>) -> Bool {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<AnyObject?>) -> AnyObject? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<NSObject?>) -> NSObject? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<NSData?>) -> NSData? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<NSData>) -> NSData {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<NSDate?>) -> NSDate? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<NSURL?>) -> NSURL? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<[String: AnyObject]?>) -> [String: AnyObject]? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<[String: AnyObject]>) -> [String: AnyObject] {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<NSDictionary?>) -> NSDictionary? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<NSDictionary>) -> NSDictionary {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    func get<T: UserDefaultsDecodable>(key: DefaultsKey<T>) -> T? {
        return storage.get(key)
    }
    func set<T: UserDefaultsDecodable>(key: DefaultsKey<T>, value: T?) {
        storage.set(key, value: value)
    }
}

