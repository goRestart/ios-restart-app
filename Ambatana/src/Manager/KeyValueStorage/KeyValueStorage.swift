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
    static let productMoreInfoTooltipDismissed = DefaultsKey<Bool>("showMoreInfoTooltip")

    static let pushPermissionsDidAskAtList = DefaultsKey<Bool>("didAskForPushPermissionsAtList")
    static let pushPermissionsDailyDate = DefaultsKey<NSDate?>("dailyPermissionDate")
    static let pushPermissionsDidShowNativeAlert = DefaultsKey<Bool>("didShowNativePushPermissionsDialog")

    static let cameraAlreadyShown = DefaultsKey<Bool>("cameraAlreadyShown")
    static let cameraAlreadyShownFreePosting = DefaultsKey<Bool>("cameraAlreadyShownFreePosting")
    static let giveAwayTooltipAlreadyShown = DefaultsKey<Bool>("giveAwayTooltipAlreadyShown")
    static let stickersTooltipAlreadyShown = DefaultsKey<Bool>("stickersTooltipAlreadyShown")
    static let userRatingTooltipAlreadyShown = DefaultsKey<Bool>("userRatingTooltipAlreadyShown")

    static let didShowCommercializer = DefaultsKey<Bool>("didShowCommercializer")
    static let isGod = DefaultsKey<Bool>("isGod")
    static let lastSearches = DefaultsKey<[String]>("lastSearches")
}


// MARK: - UserProvider

// TODO: Remove until MyUserRepository is a protocol
protocol UserProvider {
    var myUser: MyUser? { get }
}
extension MyUserRepository: UserProvider {}


// MARK: - KeyValueStorage

class KeyValueStorage {
    static let sharedInstance: KeyValueStorage = KeyValueStorage()

    private var storage: KeyValueStorageable
    private let userProvider: UserProvider


    // MARK: - Lifecycle

    init(storage: KeyValueStorageable, userProvider: UserProvider) {
        self.storage = storage
        self.userProvider = userProvider
    }

    convenience init() {
        let userProvider = Core.myUserRepository
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.init(storage: userDefaults, userProvider: userProvider)
    }
}


// MARK: - Public methods

extension KeyValueStorage {
    var userAppShared: Bool {
        get { return currentUserProperties?.appShared ?? UserDefaultsUser.appSharedDefaultValue }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.appShared = newValue
            currentUserProperties = userProperties
        }
    }
    var userLocationApproximate: Bool {
        get { return currentUserProperties?.userLocationApproximate ?? UserDefaultsUser.appSharedDefaultValue }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.userLocationApproximate = newValue
            currentUserProperties = userProperties
        }
    }
    var userChatSafetyTipsShown: Bool {
        get { return currentUserProperties?.chatSafetyTipsShown ?? UserDefaultsUser.chatSafetyTipsShownDefaultValue }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.chatSafetyTipsShown = newValue
            currentUserProperties = userProperties
        }
    }
    func userLoadChatShowDirectAnswersForKey(key: String) -> Bool {
        return currentUserProperties?.chatShowDirectAnswers[key] ?? true
    }
    func userSaveChatShowDirectAnswersForKey(key: String, value: Bool) {
        guard var userProperties = currentUserProperties else { return }
        userProperties.chatShowDirectAnswers[key] = value
        currentUserProperties = userProperties
    }
    var userRatingAlreadyRated: Bool {
        get {
            return currentUserProperties?.ratingAlreadyRated ??
                UserDefaultsUser.ratingAlreadyRatedDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.ratingAlreadyRated = newValue
            currentUserProperties = userProperties
        }
    }
    var userRatingRemindMeLaterDate: NSDate? {
        get {
            return currentUserProperties?.ratingRemindMeLaterDate ??
                UserDefaultsUser.ratingRemindMeLaterDateDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.ratingRemindMeLaterDate = newValue
            currentUserProperties = userProperties
        }
    }
    var userPostProductLastGalleryAlbumSelected: String? {
        get {
            return currentUserProperties?.postProductLastGalleryAlbumSelected ??
                UserDefaultsUser.postProductLastGalleryAlbumSelectedDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.postProductLastGalleryAlbumSelected = newValue
            currentUserProperties = userProperties
        }
    }
    var userPostProductLastTabSelected: Int {
        get {
            return currentUserProperties?.postProductLastTabSelected ??
                UserDefaultsUser.postProductLastTabSelectedDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.postProductLastTabSelected = newValue
            currentUserProperties = userProperties
        }
    }
    var userPostProductPostedPreviously: Bool {
        get {
            return currentUserProperties?.postProductPostedPreviously ??
                UserDefaultsUser.postProductPostedPreviouslyDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.postProductPostedPreviously = newValue
            currentUserProperties = userProperties
        }
    }
    var userCommercializersPending: [String:[String]] {
        get {
            return currentUserProperties?.commercializersPending ??
                UserDefaultsUser.commercializersPendingDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.commercializersPending = newValue
            currentUserProperties = userProperties
        }
    }
    var userTrackingProductSellComplete24hTracked: Bool {
        get {
            return currentUserProperties?.trackingProductSellComplete24hTracked ??
                UserDefaultsUser.trackingProductSellComplete24hTrackedDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.trackingProductSellComplete24hTracked = newValue
            currentUserProperties = userProperties
        }
    }
    var shouldShowCommercializerAfterPosting: Bool {
        get {
            return currentUserProperties?.shouldShowCommercializerAfterPosting ??
                UserDefaultsUser.shouldShowCommercializerAfterPostingDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.shouldShowCommercializerAfterPosting = newValue
            currentUserProperties = userProperties
        }
    }

    var userShouldShowExpressChat: Bool {
        get {
            return currentUserProperties?.shouldShowExpressChat ??
                UserDefaultsUser.shouldShowExpressChatDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.shouldShowExpressChat = newValue
            currentUserProperties = userProperties
        }
    }

    var userProductsWithExpressChatAlreadyShown: [String] {
        get {
            return currentUserProperties?.productsWithExpressChatAlreadyShown ??
                UserDefaultsUser.productsWithExpressChatAlreadyShownDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.productsWithExpressChatAlreadyShown = newValue
            currentUserProperties = userProperties
        }
    }

    var userProductsWithExpressChatMessageSent: [String] {
        get {
            return currentUserProperties?.productsWithExpressChatMessageSent ??
                UserDefaultsUser.productsWithExpressChatMessageSentDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.productsWithExpressChatMessageSent = newValue
            currentUserProperties = userProperties
        }
    }

    var userMarketingNotifications: Bool {
        get {
            return currentUserProperties?.marketingNotifications ??
                UserDefaultsUser.marketingNotificationsDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.marketingNotifications = newValue
            currentUserProperties = userProperties
        }
    }
}


// MARK: - Private methods

private extension KeyValueStorage {
    private var currentUserId: String? {
        return userProvider.myUser?.objectId
    }
    private var currentUserKey: DefaultsKey<UserDefaultsUser>? {
        guard let currentUserId = currentUserId else { return nil }
        return DefaultsKey<UserDefaultsUser>(currentUserId)
    }
    private var currentUserProperties: UserDefaultsUser? {
        get {
            guard let key = currentUserKey else { return nil }
            return get(key) ?? UserDefaultsUser()
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
    subscript(key: DefaultsKey<[String]>) -> [String] {
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

