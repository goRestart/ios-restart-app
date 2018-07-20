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
    static let didShowListingDetailOnboarding = DefaultsKey<Bool>("didShowProductDetailOnboarding")
    static let didShowDeckOnBoarding = DefaultsKey<Bool>("didShowDeckOnBoarding")

    static let listingMoreInfoTooltipDismissed = DefaultsKey<Bool>("showMoreInfoTooltip")
    static let favoriteCategories = DefaultsKey<[Int]>("favoriteCategories")

    static let pushPermissionsDailyDate = DefaultsKey<Date?>("dailyPermissionDate")
    static let pushPermissionsDidShowNativeAlert = DefaultsKey<Bool>("didShowNativePushPermissionsDialog")

    static let cameraAlreadyShown = DefaultsKey<Bool>("cameraAlreadyShown")
    
    // changing naming as there is no tooltip any more but keeping the string to avoid showing the badge to old users.
    static let stickersBadgeAlreadyShown = DefaultsKey<Bool>("stickersTooltipAlreadyShown")

    static let isGod = DefaultsKey<Bool>("isGod")
    static let lastSuggestiveSearches = DefaultsKey<[LocalSuggestiveSearch]>("lastSuggestiveSearches")

    static let previousUserAccountProvider = DefaultsKey<String?>("previousUserAccountProvider")
    static let previousUserEmailOrName = DefaultsKey<String?>("previousUserEmailOrName")
    static let sessionNumber = DefaultsKey<Int>("sessionNumber")
    static let postListingLastGalleryAlbumSelected = DefaultsKey<String?>("postProductLastGalleryAlbumSelected")

    static let lastShownSurveyDate = DefaultsKey<Date?>("lastShownSurveyDate")
    static let lastShownPromoteBumpDate = DefaultsKey<Date?>("lastShownPromoteBumpDate")
    static let realEstateTooltipSellButtonAlreadyShown = DefaultsKey<Bool>("realEstateTooltipSellButtonAlreadyShown")
    static let realEstateTooltipMapShown = DefaultsKey<Bool>("realEstateTooltipMapShown")
    
    static let mostSearchedItemsCameraBadgeAlreadyShown = DefaultsKey<Bool>("mostSearchedItemsBadgeAlreadyShown")
    
    static let lastShownSecurityWarningDate = DefaultsKey<Date?>("lastShownSecurityWarningDate")

    static let showOffensiveReportOnNextStart = DefaultsKey<Bool>("showOffensiveReportOnNextStart")

    static let lastShownReputationTooltipDate = DefaultsKey<Date?>("lastShownReputationTooltipDate")
    static let reputationTooltipShown = DefaultsKey<Bool>("reputationTooltipShown")

    static let machineLearningOnboardingShown = DefaultsKey<Bool>("machineLearningOnboardingShown")

    static let analyticsSessionData = DefaultsKey<AnalyticsSessionData>("analyticsSessionData")

    static let sellAutoShareOnFacebook = DefaultsKey<Bool?>("sellAutoShareOnFacebook")
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
    var userPostListingLastTabSelected: Int {
        get {
            return currentUserProperties?.postListingLastTabSelected ??
                UserDefaultsUser.postListingLastTabSelectedDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.postListingLastTabSelected = newValue
            currentUserProperties = userProperties
        }
    }
    var userPostProductPostedPreviously: Bool {
        get {
            return currentUserProperties?.postListingPostedPreviously ??
                UserDefaultsUser.postListingPostedPreviouslyDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.postListingPostedPreviously = newValue
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
            return currentUserProperties?.listingsWithExpressChatAlreadyShown ??
                UserDefaultsUser.listingsWithExpressChatAlreadyShownDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.listingsWithExpressChatAlreadyShown = newValue
            currentUserProperties = userProperties
        }
    }

    var userListingsWithExpressChatMessageSent: [String] {
        get {
            return currentUserProperties?.listingsWithExpressChatMessageSent ??
                UserDefaultsUser.listingsWithExpressChatMessageSentDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.listingsWithExpressChatMessageSent = newValue
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

    var userPendingTransactionsListingIds: [String:String] {
        get {
            return currentUserProperties?.pendingTransactionsListingIds ??
                UserDefaultsUser.transactionsListingIdsDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.pendingTransactionsListingIds = newValue
            currentUserProperties = userProperties
        }
    }

    var userFailedBumpsInfo: [String:[String:String?]] {
        get {
            return currentUserProperties?.failedBumpsInfo ??
                UserDefaultsUser.failedBumpsInfoDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.failedBumpsInfo = newValue
            currentUserProperties = userProperties
        }
    }

    var proSellerAlreadySentPhoneInChat: [String] {
        get {
            return currentUserProperties?.proSellerAlreadySentPhoneInChat ??
                UserDefaultsUser.proSellerAlreadySentPhoneInChatDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.proSellerAlreadySentPhoneInChat = newValue
            currentUserProperties = userProperties
        }
    }

    var meetingSafetyTipsAlreadyShown: Bool {
        get {
            return currentUserProperties?.meetingSafetyTipsAlreadyShown ??
                UserDefaultsUser.meetingSafetyTipsAlreadyShownDefaultValue
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.meetingSafetyTipsAlreadyShown = newValue
            currentUserProperties = userProperties
        }
    }

    var interestingListingIDs: Set<String> {
        get {
            return currentUserProperties?.interestingProducts ??
                Set(UserDefaultsUser.interestingListingsDefaultValue)
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.interestingProducts = newValue
            currentUserProperties = userProperties
        }
    }

    var analyticsSessionData: AnalyticsSessionData? {
        get {
            return currentUserProperties?.analyticsSessionData
        }
        set {
            guard var userProperties = currentUserProperties else { return }
            userProperties.analyticsSessionData = newValue
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
    subscript(key: DefaultsKey<[LocalSuggestiveSearch]>) -> [LocalSuggestiveSearch] {
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

