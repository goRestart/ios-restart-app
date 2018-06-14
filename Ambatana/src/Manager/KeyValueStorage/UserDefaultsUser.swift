//
//  UserDefaultsUser.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

struct UserDefaultsUser {
    static let appSharedDefaultValue = false
    static let userLocationApproximateDefaultValue = true
    static let chatSafetyTipsShownDefaultValue = false
    static let ratingAlreadyRatedDefaultValue = false
    static let ratingRemindMeLaterDateDefaultValue: Date? = nil
    static let postListingLastGalleryAlbumSelectedDefaultValue: String? = nil
    static let postListingLastTabSelectedDefaultValue: Int = 1
    static let postListingPostedPreviouslyDefaultValue = false
    static let trackingProductSellComplete24hTrackedDefaultValue = false
    static let shouldShowExpressChatDefaultValue = true
    static let listingsWithExpressChatAlreadyShownDefaultValue: [String] = []
    static let listingsWithExpressChatMessageSentDefaultValue: [String] = []
    static let marketingNotificationsDefaultValue = true
    static let transactionsListingIdsDefaultValue = [String:String]()

    static let failedBumpsInfoDefaultValue = [String:[String:String?]]()
    static let proSellerAlreadySentPhoneInChatDefaultValue: [String] = []
    static let machineLearningOnboardingShownDefaultValue = false
    static let meetingSafetyTipsAlreadyShownDefaultValue = false
    static let interestingListingsDefaultValue: [String] = []
    static let sessionDataDefaultValue: AnalyticsSessionData? = nil

    var appShared: Bool
    var userLocationApproximate: Bool
    var chatSafetyTipsShown: Bool
    var ratingAlreadyRated: Bool
    var ratingRemindMeLaterDate: Date?
    var postListingLastGalleryAlbumSelected: String?
    var postListingLastTabSelected: Int
    var postListingPostedPreviously: Bool
    var trackingProductSellComplete24hTracked: Bool
    var shouldShowExpressChat: Bool
    var listingsWithExpressChatAlreadyShown: [String]
    var listingsWithExpressChatMessageSent: [String]
    var marketingNotifications: Bool
    var pendingTransactionsListingIds: [String:String] // [<transactionId> : <listingId>]

    var failedBumpsInfo: [String:[String:String?]] // [<listingId> : <failedBumpInfo>]
    var proSellerAlreadySentPhoneInChat: [String]
    var machineLearningOnboardingShown: Bool
    var meetingSafetyTipsAlreadyShown: Bool

    var interestingProducts: Set<String>
    var analyticsSessionData: AnalyticsSessionData?

    init() {
        self.init(appShared: UserDefaultsUser.appSharedDefaultValue,
                  userLocationApproximate: UserDefaultsUser.userLocationApproximateDefaultValue,
                  chatSafetyTipsShown: UserDefaultsUser.chatSafetyTipsShownDefaultValue,
                  ratingAlreadyRated: UserDefaultsUser.ratingAlreadyRatedDefaultValue,
                  ratingRemindMeLaterDate: UserDefaultsUser.ratingRemindMeLaterDateDefaultValue,
                  postListingLastGalleryAlbumSelected: UserDefaultsUser.postListingLastGalleryAlbumSelectedDefaultValue,
                  postListingLastTabSelected: UserDefaultsUser.postListingLastTabSelectedDefaultValue,
                  postListingPostedPreviously: UserDefaultsUser.postListingPostedPreviouslyDefaultValue,
                  trackingProductSellComplete24hTracked: UserDefaultsUser.trackingProductSellComplete24hTrackedDefaultValue,
                  shouldShowExpressChat: UserDefaultsUser.shouldShowExpressChatDefaultValue,
                  listingsWithExpressChatAlreadyShown: UserDefaultsUser.listingsWithExpressChatAlreadyShownDefaultValue,
                  listingsWithExpressChatMessageSent: UserDefaultsUser.listingsWithExpressChatMessageSentDefaultValue,
                  marketingNotifications: UserDefaultsUser.marketingNotificationsDefaultValue,
                  pendingTransactionsListingIds: UserDefaultsUser.transactionsListingIdsDefaultValue,
                  failedBumpsInfo: UserDefaultsUser.failedBumpsInfoDefaultValue,
                  proSellerAlreadySentPhoneInChat: UserDefaultsUser.proSellerAlreadySentPhoneInChatDefaultValue,
                  machineLearningOnboardingShown: UserDefaultsUser.machineLearningOnboardingShownDefaultValue,
                  meetingSafetyTipsAlreadyShown: UserDefaultsUser.meetingSafetyTipsAlreadyShownDefaultValue,
                  interestingProducts: Set(UserDefaultsUser.interestingListingsDefaultValue),
                  analyticsSessionData: UserDefaultsUser.sessionDataDefaultValue)
    }

    init(appShared: Bool,
         userLocationApproximate: Bool,
         chatSafetyTipsShown: Bool,
         ratingAlreadyRated: Bool,
         ratingRemindMeLaterDate: Date?,
         postListingLastGalleryAlbumSelected: String?,
         postListingLastTabSelected: Int,
         postListingPostedPreviously: Bool,
         trackingProductSellComplete24hTracked: Bool,
         shouldShowExpressChat: Bool,
         listingsWithExpressChatAlreadyShown: [String],
         listingsWithExpressChatMessageSent: [String],
         marketingNotifications: Bool,
         pendingTransactionsListingIds: [String:String],
         failedBumpsInfo: [String:[String:String?]],
         proSellerAlreadySentPhoneInChat: [String],
         machineLearningOnboardingShown: Bool,
         meetingSafetyTipsAlreadyShown: Bool,
         interestingProducts: Set<String>,
         analyticsSessionData: AnalyticsSessionData?) {
        self.appShared = appShared
        self.userLocationApproximate = userLocationApproximate
        self.chatSafetyTipsShown = chatSafetyTipsShown
        self.ratingAlreadyRated = ratingAlreadyRated
        self.ratingRemindMeLaterDate = ratingRemindMeLaterDate
        self.postListingLastGalleryAlbumSelected = postListingLastGalleryAlbumSelected
        self.postListingLastTabSelected = postListingLastTabSelected
        self.postListingPostedPreviously = postListingPostedPreviously
        self.trackingProductSellComplete24hTracked = trackingProductSellComplete24hTracked
        self.shouldShowExpressChat = shouldShowExpressChat
        self.listingsWithExpressChatAlreadyShown = listingsWithExpressChatAlreadyShown
        self.listingsWithExpressChatMessageSent = listingsWithExpressChatMessageSent
        self.marketingNotifications = marketingNotifications
        self.pendingTransactionsListingIds = pendingTransactionsListingIds
        self.failedBumpsInfo = failedBumpsInfo
        self.proSellerAlreadySentPhoneInChat = proSellerAlreadySentPhoneInChat
        self.machineLearningOnboardingShown = machineLearningOnboardingShown
        self.meetingSafetyTipsAlreadyShown = meetingSafetyTipsAlreadyShown
        self.interestingProducts = interestingProducts
        self.analyticsSessionData = analyticsSessionData
    }
}


// MARK: - UserDefaultsDecodable

extension UserDefaultsUser: UserDefaultsDecodable {
    static func decode(_ dictionary: [String: Any]) -> UserDefaultsUser? {
        let appShared = dictionary.decode(UserDefaultsUserKey.appShared.rawValue,
                                          defaultValue: UserDefaultsUser.appSharedDefaultValue)
        let userLocationApproximate = dictionary.decode(UserDefaultsUserKey.userLocationApproximate.rawValue,
                                                        defaultValue: UserDefaultsUser.userLocationApproximateDefaultValue)
        let chatSafetyTipsShown = dictionary.decode(UserDefaultsUserKey.chatSafetyTipsShown.rawValue,
                                                    defaultValue: UserDefaultsUser.chatSafetyTipsShownDefaultValue)
        let ratingAlreadyRated = dictionary.decode(UserDefaultsUserKey.ratingAlreadyRated.rawValue,
                                                   defaultValue: UserDefaultsUser.ratingAlreadyRatedDefaultValue)
        let ratingRemindMeLaterDate: Date? = dictionary.decode(UserDefaultsUserKey.ratingRemindMeLaterDate.rawValue,
                                                                 defaultValue: UserDefaultsUser.ratingRemindMeLaterDateDefaultValue)
        let postListingLastGalleryAlbumSelected: String? = dictionary.decode(UserDefaultsUserKey.postListingLastGalleryAlbumSelected.rawValue,
                                                                             defaultValue: UserDefaultsUser.postListingLastGalleryAlbumSelectedDefaultValue)
        let postListingLastTabSelected = dictionary.decode(UserDefaultsUserKey.postListingLastTabSelected.rawValue,
                                                           defaultValue: UserDefaultsUser.postListingLastTabSelectedDefaultValue)
        let postListingPostedPreviously = dictionary.decode(UserDefaultsUserKey.postListingPostedPreviously.rawValue,
                                                           defaultValue: UserDefaultsUser.postListingPostedPreviouslyDefaultValue)

        let trackingProductSellComplete24hTracked = dictionary.decode(UserDefaultsUserKey.trackingProductSellComplete24hTracked.rawValue,
                                                                      defaultValue: UserDefaultsUser.trackingProductSellComplete24hTrackedDefaultValue)
        let shouldShowExpressChat = dictionary.decode(UserDefaultsUserKey.shouldShowExpressChat.rawValue,
                                                      defaultValue: UserDefaultsUser.shouldShowExpressChatDefaultValue)
        let listingsWithExpressChatAlreadyShown = dictionary.decode(UserDefaultsUserKey.listingsWithExpressChatAlreadyShown.rawValue,
                                                                    defaultValue: UserDefaultsUser.listingsWithExpressChatAlreadyShownDefaultValue)
        let listingsWithExpressChatMessageSent = dictionary.decode(UserDefaultsUserKey.listingsWithExpressChatMessageSent.rawValue,
                                                                   defaultValue: UserDefaultsUser.listingsWithExpressChatMessageSentDefaultValue)
        let marketingNotifications = dictionary.decode(UserDefaultsUserKey.marketingNotifications.rawValue,
                                                       defaultValue: UserDefaultsUser.marketingNotificationsDefaultValue)
        let pendingTransactionsListingIds = dictionary.decode(UserDefaultsUserKey.pendingTransactionsListingIds.rawValue, defaultValue: UserDefaultsUser.transactionsListingIdsDefaultValue)
        let failedBumpsInfo = dictionary.decode(UserDefaultsUserKey.failedBumpsInfo.rawValue, defaultValue: UserDefaultsUser.failedBumpsInfoDefaultValue)
        let proSellerAlreadySentPhoneInChat = dictionary.decode(UserDefaultsUserKey.proSellerAlreadySentPhoneInChat.rawValue,
                                                                defaultValue: UserDefaultsUser.proSellerAlreadySentPhoneInChatDefaultValue)
        let machineLearningOnboardingShown = dictionary.decode(UserDefaultsUserKey.machineLearningOnboardingShown.rawValue,
                                                                defaultValue: UserDefaultsUser.machineLearningOnboardingShownDefaultValue)

        let meetingSafetyTipsAlreadyShown = dictionary.decode(UserDefaultsUserKey.meetingSafetyTipsAlreadyShown.rawValue,
                                                              defaultValue: UserDefaultsUser.meetingSafetyTipsAlreadyShownDefaultValue)
        let interestingProducts: [String] = dictionary.decode(UserDefaultsUserKey.interestingProducts.rawValue,
                                                              defaultValue: UserDefaultsUser.interestingListingsDefaultValue)
        let analyticsSessionData = dictionary.decode(UserDefaultsUserKey.analyticsSessionData.rawValue,
                                                     defaultValue: UserDefaultsUser.sessionDataDefaultValue)
        return UserDefaultsUser(appShared: appShared,
                                userLocationApproximate: userLocationApproximate,
                                chatSafetyTipsShown: chatSafetyTipsShown,
                                ratingAlreadyRated: ratingAlreadyRated,
                                ratingRemindMeLaterDate: ratingRemindMeLaterDate,
                                postListingLastGalleryAlbumSelected: postListingLastGalleryAlbumSelected,
                                postListingLastTabSelected: postListingLastTabSelected,
                                postListingPostedPreviously:  postListingPostedPreviously,
                                trackingProductSellComplete24hTracked: trackingProductSellComplete24hTracked,
                                shouldShowExpressChat: shouldShowExpressChat,
                                listingsWithExpressChatAlreadyShown: listingsWithExpressChatAlreadyShown,
                                listingsWithExpressChatMessageSent: listingsWithExpressChatMessageSent,
                                marketingNotifications: marketingNotifications,
                                pendingTransactionsListingIds: pendingTransactionsListingIds,
                                failedBumpsInfo: failedBumpsInfo,
                                proSellerAlreadySentPhoneInChat: proSellerAlreadySentPhoneInChat,
                                machineLearningOnboardingShown: machineLearningOnboardingShown,
                                meetingSafetyTipsAlreadyShown: meetingSafetyTipsAlreadyShown,
                                interestingProducts: Set(interestingProducts),
                                analyticsSessionData: analyticsSessionData)
    }

    func encode() -> [String: Any] {
        var dict = [String: Any]()
        dict.encode(UserDefaultsUserKey.appShared.rawValue, value: appShared)
        dict.encode(UserDefaultsUserKey.userLocationApproximate.rawValue, value: userLocationApproximate)
        dict.encode(UserDefaultsUserKey.chatSafetyTipsShown.rawValue, value: chatSafetyTipsShown)
        dict.encode(UserDefaultsUserKey.ratingAlreadyRated.rawValue, value: ratingAlreadyRated)
        if let ratingRemindMeLaterDate = ratingRemindMeLaterDate {
            dict.encode(UserDefaultsUserKey.ratingRemindMeLaterDate.rawValue, value: ratingRemindMeLaterDate)
        }
        dict.encode(UserDefaultsUserKey.ratingAlreadyRated.rawValue, value: ratingAlreadyRated)
        if let postListingLastGalleryAlbumSelected = postListingLastGalleryAlbumSelected {
            dict.encode(UserDefaultsUserKey.postListingLastGalleryAlbumSelected.rawValue, value: postListingLastGalleryAlbumSelected)
        }
        dict.encode(UserDefaultsUserKey.postListingLastTabSelected.rawValue, value: postListingLastTabSelected)
        dict.encode(UserDefaultsUserKey.postListingPostedPreviously.rawValue, value: postListingPostedPreviously)
        dict.encode(UserDefaultsUserKey.trackingProductSellComplete24hTracked.rawValue, value: trackingProductSellComplete24hTracked)
        dict.encode(UserDefaultsUserKey.shouldShowExpressChat.rawValue, value: shouldShowExpressChat)
        dict.encode(UserDefaultsUserKey.listingsWithExpressChatAlreadyShown.rawValue, value: listingsWithExpressChatAlreadyShown)
        dict.encode(UserDefaultsUserKey.listingsWithExpressChatMessageSent.rawValue, value: listingsWithExpressChatMessageSent)
        dict.encode(UserDefaultsUserKey.marketingNotifications.rawValue, value: marketingNotifications)
        dict.encode(UserDefaultsUserKey.pendingTransactionsListingIds.rawValue, value: pendingTransactionsListingIds)
        dict.encode(UserDefaultsUserKey.failedBumpsInfo.rawValue, value: failedBumpsInfo)
        dict.encode(UserDefaultsUserKey.proSellerAlreadySentPhoneInChat.rawValue, value: proSellerAlreadySentPhoneInChat)
        dict.encode(UserDefaultsUserKey.machineLearningOnboardingShown.rawValue, value: machineLearningOnboardingShown)
        dict.encode(UserDefaultsUserKey.meetingSafetyTipsAlreadyShown.rawValue, value: meetingSafetyTipsAlreadyShown)
        dict.encode(UserDefaultsUserKey.interestingProducts.rawValue, value: Array(interestingProducts))
        if let analyticsSessionData = analyticsSessionData {
            dict.encode(UserDefaultsUserKey.analyticsSessionData.rawValue, value: analyticsSessionData.encode())
        }
        return dict
    }
}


// MARK: - Private
// MARK: > UserDefaults user keys

private enum UserDefaultsUserKey: String {
    case appShared = "alreadyShared"

    case userLocationApproximate = "isApproximateLocation"

    case chatSafetyTipsShown = "chatSafetyTipsShown"

    case ratingAlreadyRated = "alreadyRated"
    case ratingRemindMeLaterDate = "remindMeLater"

    case postListingLastGalleryAlbumSelected = "lastGalleryAlbumSelected"
    case postListingLastTabSelected = "lastPostProductTabSelected"
    case postListingPostedPreviously = "postProductPostedPreviously"

    case trackingProductSellComplete24hTracked = "trackingProductSellComplete24hTracked"

    case shouldShowExpressChat = "shouldShowExpressChat"
    case listingsWithExpressChatAlreadyShown = "productsWithExpressChatAlreadyShown"
    case listingsWithExpressChatMessageSent = "productsWithExpressChatMessageSent"
    case marketingNotifications = "marketingNotifications"

    case pendingTransactionsListingIds = "pendingTransactionsListingIds"

    case failedBumpsInfo = "failedBumpsInfo"

    case proSellerAlreadySentPhoneInChat = "proSellerAlreadySentPhoneInChat"
    
    case machineLearningOnboardingShown = "machineLearningOnboardingShown"

    case meetingSafetyTipsAlreadyShown = "meetingSafetyTipsAlreadyShown"
    case interestingProducts = "interestingProducts"

    case analyticsSessionData = "analyticsSessionData"
}


// MARK: > Dictionary helper

fileprivate extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    func decode<T>(_ key: Key, defaultValue: T) -> T {
        return (self[key] as? T) ?? defaultValue
    }
    mutating func encode(_ key: Key, value: Value) {
        self[key] = value
    }
}
