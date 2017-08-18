//
//  KeyValueStorage.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import SwiftyUserDefaults
import RxSwift

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

    static let firstRunDate = DefaultsKey<Date?>("firstOpenDate")
    static let lastRunAppVersion = DefaultsKey<String?>("lastRunAppVersion")

    static let didShowOnboarding = DefaultsKey<Bool>("didShowOnboarding")
    static let didShowProductDetailOnboarding = DefaultsKey<Bool>("didShowProductDetailOnboarding")
    static let didShowHorizontalProductDetailOnboarding = DefaultsKey<Bool>("didShowHorizontalProductDetailOnboarding")
    static let productDetailQuickAnswersHidden = DefaultsKey<Bool>("productDetailQuickAnswers")
    static let productMoreInfoTooltipDismissed = DefaultsKey<Bool>("showMoreInfoTooltip")
    static let favoriteCategories = DefaultsKey<[Int]>("favoriteCategories")

    static let pushPermissionsDailyDate = DefaultsKey<Date?>("dailyPermissionDate")
    static let pushPermissionsDidShowNativeAlert = DefaultsKey<Bool>("didShowNativePushPermissionsDialog")

    static let cameraAlreadyShown = DefaultsKey<Bool>("cameraAlreadyShown")
    
    // changing naming as there is no tooltip any more but keeping the string to avoid showing the badge to old users.
    static let stickersBadgeAlreadyShown = DefaultsKey<Bool>("stickersTooltipAlreadyShown")
    static let userRatingTooltipAlreadyShown = DefaultsKey<Bool>("userRatingTooltipAlreadyShown")

    static let isGod = DefaultsKey<Bool>("isGod")
    static let lastSearches = DefaultsKey<[String]>("lastSearches")

    static let previousUserAccountProvider = DefaultsKey<String?>("previousUserAccountProvider")
    static let previousUserEmailOrName = DefaultsKey<String?>("previousUserEmailOrName")
    static let sessionNumber = DefaultsKey<Int>("sessionNumber")
    static let postProductLastGalleryAlbumSelected = DefaultsKey<String?>("postProductLastGalleryAlbumSelected")

    static let lastShownSurveyDate = DefaultsKey<Date?>("lastShownSurveyDate")
}


// MARK: - KeyValueStorage

class KeyValueStorage {
    static let sharedInstance: KeyValueStorage = KeyValueStorage()

    fileprivate var storage: KeyValueStorageable
    fileprivate let myUserRepository: MyUserRepository
    
    
    var currentUserId: String? {
        return myUserRepository.myUser?.objectId
    }
    var currentUserKey: DefaultsKey<UserDefaultsUser>? {
        guard let currentUserId = currentUserId else { return nil }
        return DefaultsKey<UserDefaultsUser>(currentUserId)
    }
    
    var favoriteCategoriesSelected = Variable<Bool>(false)


    // MARK: - Lifecycle

    init(storage: KeyValueStorageable, myUserRepository: MyUserRepository) {
        self.storage = storage
        self.myUserRepository = myUserRepository
    }

    convenience init() {
        let myUserRepository = Core.myUserRepository
        let userDefaults = StorageableUserDefaults(userDefaults: UserDefaults.standard)
        self.init(storage: userDefaults, myUserRepository: myUserRepository)
    }
}


// MARK: - Public methods

extension KeyValueStorageable {
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
    func userLoadChatShowDirectAnswersForKey(_ key: String) -> Bool {
        return currentUserProperties?.chatShowDirectAnswers[key] ?? true
    }
    func userSaveChatShowDirectAnswersForKey(_ key: String, value: Bool) {
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
    var userRatingRemindMeLaterDate: Date? {
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

    var userPendingTransactionsProductIds: [String:String] {
        get {
            return currentUserProperties?.pendingTransactionsProductIds ??
                UserDefaultsUser.transactionsProductIdsDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.pendingTransactionsProductIds = newValue
            currentUserProperties = userProperties
        }
    }
}


// MARK: - KeyValueStorageable

extension KeyValueStorage: KeyValueStorageable {
    
    var currentUserProperties: UserDefaultsUser? {
        get {
            guard let key = currentUserKey else { return nil }
            return get(key) ?? UserDefaultsUser()
        }
        set {
            guard let key = currentUserKey else { return }
            set(key, value: newValue)
        }
    }
    
    subscript(key: DefaultsKey<String?>) -> String? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<String>) -> String {
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
    subscript(key: DefaultsKey<Any?>) -> Any? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<Data?>) -> Data? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<Data>) -> Data {
        get { return storage[key] as Data }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<Date?>) -> Date? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<URL?>) -> URL? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<[String: Any]?>) -> [String: Any]? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<[String: Any]>) -> [String: Any] {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<[String]>) -> [String] {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    subscript(key: DefaultsKey<[Int]>) -> [Int] {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    func get<T: UserDefaultsDecodable>(_ key: DefaultsKey<T>) -> T? {
        return storage.get(key)
    }
    func set<T: UserDefaultsDecodable>(_ key: DefaultsKey<T>, value: T?) {
        storage.set(key, value: value)
    }
}

