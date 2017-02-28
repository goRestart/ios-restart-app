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
    static let chatShowDirectAnswersDefaultValue = [String:Bool]()
    static let ratingAlreadyRatedDefaultValue = false
    static let ratingRemindMeLaterDateDefaultValue: Date? = nil
    static let postProductLastGalleryAlbumSelectedDefaultValue: String? = nil
    static let postProductLastTabSelectedDefaultValue = 1
    static let postProductPostedPreviouslyDefaultValue = false
    static let commercializersPendingDefaultValue = [String:[String]]()
    static let trackingProductSellComplete24hTrackedDefaultValue = false
    static let shouldShowExpressChatDefaultValue = true
    static let productsWithExpressChatAlreadyShownDefaultValue: [String] = []
    static let productsWithExpressChatMessageSentDefaultValue: [String] = []
    static let marketingNotificationsDefaultValue = true
    static let productsMarkAsFavoriteDafaultValue: Int? = nil
    static let transactionsProductIdsDefaultValue = [String:String]()

    var appShared: Bool
    var userLocationApproximate: Bool
    var chatSafetyTipsShown: Bool
    var chatShowDirectAnswers: [String:Bool] // <id>: <value>
    var ratingAlreadyRated: Bool
    var ratingRemindMeLaterDate: Date?
    var postProductLastGalleryAlbumSelected: String?
    var postProductLastTabSelected: Int
    var postProductPostedPreviously: Bool
    var commercializersPending: [String:[String]] // <id>: [<value>,...]
    var trackingProductSellComplete24hTracked: Bool
    var shouldShowExpressChat: Bool
    var productsWithExpressChatAlreadyShown: [String]
    var productsWithExpressChatMessageSent: [String]
    var marketingNotifications: Bool
    var productsMarkAsFavorite: Int?
    var transactionsProductIds: [String:String] // [<transactionId> : <productId>]

    init() {
        let appShared = UserDefaultsUser.appSharedDefaultValue
        let userLocationApproximate = UserDefaultsUser.userLocationApproximateDefaultValue
        let chatSafetyTipsShown = UserDefaultsUser.chatSafetyTipsShownDefaultValue
        let ratingAlreadyRated = UserDefaultsUser.ratingAlreadyRatedDefaultValue
        let ratingRemindMeLaterDate = UserDefaultsUser.ratingRemindMeLaterDateDefaultValue
        let chatShowDirectAnswers = UserDefaultsUser.chatShowDirectAnswersDefaultValue
        let postProductLastGalleryAlbumSelected = UserDefaultsUser.postProductLastGalleryAlbumSelectedDefaultValue
        let postProductLastTabSelected = UserDefaultsUser.postProductLastTabSelectedDefaultValue
        let postProductPostedPreviously = UserDefaultsUser.postProductPostedPreviouslyDefaultValue
        let commercializersPending = UserDefaultsUser.commercializersPendingDefaultValue
        let trackingProductSellComplete24hTracked = UserDefaultsUser.trackingProductSellComplete24hTrackedDefaultValue
        let shouldShowExpressChat = UserDefaultsUser.shouldShowExpressChatDefaultValue
        let productsWithExpressChatAlreadyShown = UserDefaultsUser.productsWithExpressChatAlreadyShownDefaultValue
        let productsWithExpressChatMessageSent = UserDefaultsUser.productsWithExpressChatMessageSentDefaultValue
        let marketingNotifications = UserDefaultsUser.marketingNotificationsDefaultValue
        let productsMarkAsFavorite = UserDefaultsUser.productsMarkAsFavoriteDafaultValue
        let transactionsProductIds = UserDefaultsUser.transactionsProductIdsDefaultValue

        self.init(appShared: appShared, userLocationApproximate: userLocationApproximate,
                  chatSafetyTipsShown: chatSafetyTipsShown, ratingAlreadyRated: ratingAlreadyRated,
                  ratingRemindMeLaterDate: ratingRemindMeLaterDate, chatShowDirectAnswers: chatShowDirectAnswers,
                  postProductLastGalleryAlbumSelected: postProductLastGalleryAlbumSelected,
                  postProductLastTabSelected: postProductLastTabSelected, postProductPostedPreviously: postProductPostedPreviously,
                  commercializersPending: commercializersPending,
                  trackingProductSellComplete24hTracked: trackingProductSellComplete24hTracked,
                  shouldShowExpressChat: shouldShowExpressChat,
                  productsWithExpressChatAlreadyShown: productsWithExpressChatAlreadyShown,
                  productsWithExpressChatMessageSent: productsWithExpressChatMessageSent,
                  marketingNotifications: marketingNotifications, productsMarkAsFavorite: productsMarkAsFavorite,
                  transactionsProductIds: transactionsProductIds)
    }

    init(appShared: Bool, userLocationApproximate: Bool, chatSafetyTipsShown: Bool, ratingAlreadyRated: Bool,
         ratingRemindMeLaterDate: Date?, chatShowDirectAnswers: [String: Bool],
         postProductLastGalleryAlbumSelected: String?, postProductLastTabSelected: Int, postProductPostedPreviously: Bool,
         commercializersPending: [String:[String]], trackingProductSellComplete24hTracked: Bool,
         shouldShowExpressChat: Bool, productsWithExpressChatAlreadyShown: [String],
         productsWithExpressChatMessageSent: [String], marketingNotifications: Bool, productsMarkAsFavorite: Int?,
         transactionsProductIds: [String:String]) {
        self.appShared = appShared
        self.userLocationApproximate = userLocationApproximate
        self.chatSafetyTipsShown = chatSafetyTipsShown
        self.ratingAlreadyRated = ratingAlreadyRated
        self.ratingRemindMeLaterDate = ratingRemindMeLaterDate
        self.chatShowDirectAnswers = chatShowDirectAnswers
        self.postProductLastGalleryAlbumSelected = postProductLastGalleryAlbumSelected
        self.postProductLastTabSelected = postProductLastTabSelected
        self.postProductPostedPreviously = postProductPostedPreviously
        self.commercializersPending = commercializersPending
        self.trackingProductSellComplete24hTracked = trackingProductSellComplete24hTracked
        self.shouldShowExpressChat = shouldShowExpressChat
        self.productsWithExpressChatAlreadyShown = productsWithExpressChatAlreadyShown
        self.productsWithExpressChatMessageSent = productsWithExpressChatMessageSent
        self.marketingNotifications = marketingNotifications
        self.productsMarkAsFavorite = productsMarkAsFavorite
        self.transactionsProductIds = transactionsProductIds
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
        let chatShowDirectAnswers = dictionary.decode(UserDefaultsUserKey.chatDirectAnswersShow.rawValue,
                                                      defaultValue: UserDefaultsUser.chatShowDirectAnswersDefaultValue)
        let ratingAlreadyRated = dictionary.decode(UserDefaultsUserKey.ratingAlreadyRated.rawValue,
                                                   defaultValue: UserDefaultsUser.ratingAlreadyRatedDefaultValue)
        let ratingRemindMeLaterDate: Date? = dictionary.decode(UserDefaultsUserKey.ratingRemindMeLaterDate.rawValue,
                                                                 defaultValue: UserDefaultsUser.ratingRemindMeLaterDateDefaultValue)
        let postProductLastGalleryAlbumSelected: String? = dictionary.decode(UserDefaultsUserKey.postProductLastGalleryAlbumSelected.rawValue,
                                                                             defaultValue: UserDefaultsUser.postProductLastGalleryAlbumSelectedDefaultValue)
        let postProductLastTabSelected = dictionary.decode(UserDefaultsUserKey.postProductLastTabSelected.rawValue,
                                                           defaultValue: UserDefaultsUser.postProductLastTabSelectedDefaultValue)
        let postProductPostedPreviously = dictionary.decode(UserDefaultsUserKey.postProductPostedPreviously.rawValue,
                                                           defaultValue: UserDefaultsUser.postProductPostedPreviouslyDefaultValue)
        let commercializersPending = dictionary.decode(UserDefaultsUserKey.commercializersPending.rawValue,
                                                       defaultValue: UserDefaultsUser.commercializersPendingDefaultValue)
        let trackingProductSellComplete24hTracked = dictionary.decode(UserDefaultsUserKey.trackingProductSellComplete24hTracked.rawValue,
                                                                      defaultValue: UserDefaultsUser.trackingProductSellComplete24hTrackedDefaultValue)

        let shouldShowExpressChat = dictionary.decode(UserDefaultsUserKey.shouldShowExpressChat.rawValue, defaultValue: UserDefaultsUser.shouldShowExpressChatDefaultValue)
        let productsWithExpressChatAlreadyShown = dictionary.decode(UserDefaultsUserKey.productsWithExpressChatAlreadyShown.rawValue, defaultValue: UserDefaultsUser.productsWithExpressChatAlreadyShownDefaultValue)
        let productsWithExpressChatMessageSent = dictionary.decode(UserDefaultsUserKey.productsWithExpressChatMessageSent.rawValue, defaultValue: UserDefaultsUser.productsWithExpressChatMessageSentDefaultValue)
        let marketingNotifications = dictionary.decode(UserDefaultsUserKey.marketingNotifications.rawValue, defaultValue: UserDefaultsUser.marketingNotificationsDefaultValue)
        let productsMarkAsFavorite = dictionary.decode(UserDefaultsUserKey.productsMarkAsFavorite.rawValue, defaultValue: UserDefaultsUser.productsMarkAsFavoriteDafaultValue)
        let transactionsProductIds = dictionary.decode(UserDefaultsUserKey.transactionsProductIds.rawValue, defaultValue: UserDefaultsUser.transactionsProductIdsDefaultValue)

        return UserDefaultsUser(appShared: appShared, userLocationApproximate: userLocationApproximate,
                                chatSafetyTipsShown: chatSafetyTipsShown, ratingAlreadyRated: ratingAlreadyRated,
                                ratingRemindMeLaterDate: ratingRemindMeLaterDate,
                                chatShowDirectAnswers: chatShowDirectAnswers,
                                postProductLastGalleryAlbumSelected: postProductLastGalleryAlbumSelected,
                                postProductLastTabSelected: postProductLastTabSelected,
                                postProductPostedPreviously:  postProductPostedPreviously,
                                commercializersPending: commercializersPending,
                                trackingProductSellComplete24hTracked: trackingProductSellComplete24hTracked,
                                shouldShowExpressChat: shouldShowExpressChat,
                                productsWithExpressChatAlreadyShown: productsWithExpressChatAlreadyShown,
                                productsWithExpressChatMessageSent: productsWithExpressChatMessageSent,
                                marketingNotifications: marketingNotifications, productsMarkAsFavorite: productsMarkAsFavorite,
                                transactionsProductIds: transactionsProductIds)
    }

    func encode() -> [String: Any] {
        var dict = [String: Any]()
        dict.encode(UserDefaultsUserKey.appShared.rawValue, value: appShared)
        dict.encode(UserDefaultsUserKey.userLocationApproximate.rawValue, value: userLocationApproximate)
        dict.encode(UserDefaultsUserKey.chatSafetyTipsShown.rawValue, value: chatSafetyTipsShown)
        dict.encode(UserDefaultsUserKey.chatDirectAnswersShow.rawValue, value: chatShowDirectAnswers)
        dict.encode(UserDefaultsUserKey.ratingAlreadyRated.rawValue, value: ratingAlreadyRated)
        if let ratingRemindMeLaterDate = ratingRemindMeLaterDate {
            dict.encode(UserDefaultsUserKey.ratingRemindMeLaterDate.rawValue, value: ratingRemindMeLaterDate)
        }
        dict.encode(UserDefaultsUserKey.ratingAlreadyRated.rawValue, value: ratingAlreadyRated)
        if let postProductLastGalleryAlbumSelected = postProductLastGalleryAlbumSelected {
            dict.encode(UserDefaultsUserKey.postProductLastGalleryAlbumSelected.rawValue, value: postProductLastGalleryAlbumSelected)
        }
        dict.encode(UserDefaultsUserKey.postProductLastTabSelected.rawValue, value: postProductLastTabSelected)
        dict.encode(UserDefaultsUserKey.postProductPostedPreviously.rawValue, value: postProductPostedPreviously)
        dict.encode(UserDefaultsUserKey.commercializersPending.rawValue, value: commercializersPending)
        dict.encode(UserDefaultsUserKey.trackingProductSellComplete24hTracked.rawValue, value: trackingProductSellComplete24hTracked)
        dict.encode(UserDefaultsUserKey.shouldShowExpressChat.rawValue, value: shouldShowExpressChat)
        dict.encode(UserDefaultsUserKey.productsWithExpressChatAlreadyShown.rawValue, value: productsWithExpressChatAlreadyShown)
        dict.encode(UserDefaultsUserKey.productsWithExpressChatMessageSent.rawValue, value: productsWithExpressChatMessageSent)
        dict.encode(UserDefaultsUserKey.marketingNotifications.rawValue, value: marketingNotifications)
        dict.encode(UserDefaultsUserKey.transactionsProductIds.rawValue, value: transactionsProductIds)
        if let productsMarkAsFavorite = productsMarkAsFavorite {
            dict.encode(UserDefaultsUserKey.productsMarkAsFavorite.rawValue, value: productsMarkAsFavorite)
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
    case chatDirectAnswersShow = "showDirectAnswers"

    case ratingAlreadyRated = "alreadyRated"
    case ratingRemindMeLaterDate = "remindMeLater"

    case postProductLastGalleryAlbumSelected = "lastGalleryAlbumSelected"
    case postProductLastTabSelected = "lastPostProductTabSelected"
    case postProductPostedPreviously = "postProductPostedPreviously"

    case commercializersPending = "pendingCommercializers"

    case trackingProductSellComplete24hTracked = "trackingProductSellComplete24hTracked"

    case shouldShowExpressChat = "shouldShowExpressChat"
    case productsWithExpressChatAlreadyShown = "productsWithExpressChatAlreadyShown"
    case productsWithExpressChatMessageSent = "productsWithExpressChatMessageSent"
    case marketingNotifications = "marketingNotifications"
    case productsMarkAsFavorite = "productsMarkAsFavorite"

    case transactionsProductIds = "transactionsProductIds"
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
