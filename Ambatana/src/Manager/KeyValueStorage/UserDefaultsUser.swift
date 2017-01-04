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
                  marketingNotifications: marketingNotifications, productsMarkAsFavorite: productsMarkAsFavorite)
    }

    init(appShared: Bool, userLocationApproximate: Bool, chatSafetyTipsShown: Bool, ratingAlreadyRated: Bool,
         ratingRemindMeLaterDate: Date?, chatShowDirectAnswers: [String: Bool],
         postProductLastGalleryAlbumSelected: String?, postProductLastTabSelected: Int, postProductPostedPreviously: Bool,
         commercializersPending: [String:[String]], trackingProductSellComplete24hTracked: Bool,
         shouldShowExpressChat: Bool, productsWithExpressChatAlreadyShown: [String],
         productsWithExpressChatMessageSent: [String], marketingNotifications: Bool, productsMarkAsFavorite: Int?) {
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
    }
}


// MARK: - UserDefaultsDecodable

extension UserDefaultsUser: UserDefaultsDecodable {
    static func decode(_ dictionary: [String: AnyObject]) -> UserDefaultsUser? {
        let appShared = dictionary.decode(UserDefaultsUserKey.AppShared.rawValue,
                                          defaultValue: UserDefaultsUser.appSharedDefaultValue)
        let userLocationApproximate = dictionary.decode(UserDefaultsUserKey.UserLocationApproximate.rawValue,
                                                        defaultValue: UserDefaultsUser.userLocationApproximateDefaultValue)
        let chatSafetyTipsShown = dictionary.decode(UserDefaultsUserKey.ChatSafetyTipsShown.rawValue,
                                                    defaultValue: UserDefaultsUser.chatSafetyTipsShownDefaultValue)
        let chatShowDirectAnswers = dictionary.decode(UserDefaultsUserKey.ChatDirectAnswersShow.rawValue,
                                                      defaultValue: UserDefaultsUser.chatShowDirectAnswersDefaultValue)
        let ratingAlreadyRated = dictionary.decode(UserDefaultsUserKey.RatingAlreadyRated.rawValue,
                                                   defaultValue: UserDefaultsUser.ratingAlreadyRatedDefaultValue)
        let ratingRemindMeLaterDate: Date? = dictionary.decode(UserDefaultsUserKey.RatingRemindMeLaterDate.rawValue,
                                                                 defaultValue: UserDefaultsUser.ratingRemindMeLaterDateDefaultValue)
        let postProductLastGalleryAlbumSelected: String? = dictionary.decode(UserDefaultsUserKey.PostProductLastGalleryAlbumSelected.rawValue,
                                                                             defaultValue: UserDefaultsUser.postProductLastGalleryAlbumSelectedDefaultValue)
        let postProductLastTabSelected = dictionary.decode(UserDefaultsUserKey.PostProductLastTabSelected.rawValue,
                                                           defaultValue: UserDefaultsUser.postProductLastTabSelectedDefaultValue)
        let postProductPostedPreviously = dictionary.decode(UserDefaultsUserKey.PostProductPostedPreviously.rawValue,
                                                           defaultValue: UserDefaultsUser.postProductPostedPreviouslyDefaultValue)
        let commercializersPending = dictionary.decode(UserDefaultsUserKey.CommercializersPending.rawValue,
                                                       defaultValue: UserDefaultsUser.commercializersPendingDefaultValue)
        let trackingProductSellComplete24hTracked = dictionary.decode(UserDefaultsUserKey.TrackingProductSellComplete24hTracked.rawValue,
                                                                      defaultValue: UserDefaultsUser.trackingProductSellComplete24hTrackedDefaultValue)

        let shouldShowExpressChat = dictionary.decode(UserDefaultsUserKey.ShouldShowExpressChat.rawValue, defaultValue: UserDefaultsUser.shouldShowExpressChatDefaultValue)
        let productsWithExpressChatAlreadyShown = dictionary.decode(UserDefaultsUserKey.ProductsWithExpressChatAlreadyShown.rawValue, defaultValue: UserDefaultsUser.productsWithExpressChatAlreadyShownDefaultValue)
        let productsWithExpressChatMessageSent = dictionary.decode(UserDefaultsUserKey.ProductsWithExpressChatMessageSent.rawValue, defaultValue: UserDefaultsUser.productsWithExpressChatMessageSentDefaultValue)
        let marketingNotifications = dictionary.decode(UserDefaultsUserKey.MarketingNotifications.rawValue, defaultValue: UserDefaultsUser.marketingNotificationsDefaultValue)
        let productsMarkAsFavorite = dictionary.decode(UserDefaultsUserKey.ProductsMarkAsFavorite.rawValue, defaultValue: UserDefaultsUser.productsMarkAsFavoriteDafaultValue)
        
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
                                marketingNotifications: marketingNotifications, productsMarkAsFavorite: productsMarkAsFavorite)
    }

    func encode() -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        dict.encode(UserDefaultsUserKey.AppShared.rawValue, value: appShared as AnyObject)
        dict.encode(UserDefaultsUserKey.UserLocationApproximate.rawValue, value: userLocationApproximate as AnyObject)
        dict.encode(UserDefaultsUserKey.ChatSafetyTipsShown.rawValue, value: chatSafetyTipsShown as AnyObject)
        dict.encode(UserDefaultsUserKey.ChatDirectAnswersShow.rawValue, value: chatShowDirectAnswers as AnyObject)
        dict.encode(UserDefaultsUserKey.RatingAlreadyRated.rawValue, value: ratingAlreadyRated as AnyObject)
        if let ratingRemindMeLaterDate = ratingRemindMeLaterDate {
            dict.encode(UserDefaultsUserKey.RatingRemindMeLaterDate.rawValue, value: ratingRemindMeLaterDate as AnyObject)
        }
        dict.encode(UserDefaultsUserKey.RatingAlreadyRated.rawValue, value: ratingAlreadyRated as AnyObject)
        if let postProductLastGalleryAlbumSelected = postProductLastGalleryAlbumSelected {
            dict.encode(UserDefaultsUserKey.PostProductLastGalleryAlbumSelected.rawValue, value: postProductLastGalleryAlbumSelected as AnyObject)
        }
        dict.encode(UserDefaultsUserKey.PostProductLastTabSelected.rawValue, value: postProductLastTabSelected as AnyObject)
        dict.encode(UserDefaultsUserKey.PostProductPostedPreviously.rawValue, value: postProductPostedPreviously as AnyObject)
        dict.encode(UserDefaultsUserKey.CommercializersPending.rawValue, value: commercializersPending as AnyObject)
        dict.encode(UserDefaultsUserKey.TrackingProductSellComplete24hTracked.rawValue, value: trackingProductSellComplete24hTracked as AnyObject)
        dict.encode(UserDefaultsUserKey.ShouldShowExpressChat.rawValue, value: shouldShowExpressChat as AnyObject)
        dict.encode(UserDefaultsUserKey.ProductsWithExpressChatAlreadyShown.rawValue, value: productsWithExpressChatAlreadyShown as AnyObject)
        dict.encode(UserDefaultsUserKey.ProductsWithExpressChatMessageSent.rawValue, value: productsWithExpressChatMessageSent as AnyObject)
        dict.encode(UserDefaultsUserKey.MarketingNotifications.rawValue, value: marketingNotifications as AnyObject)
        if let productsMarkAsFavorite = productsMarkAsFavorite {
            dict.encode(UserDefaultsUserKey.ProductsMarkAsFavorite.rawValue, value: productsMarkAsFavorite as AnyObject)
        }
        return dict
    }
}


// MARK: - Private
// MARK: > UserDefaults user keys

private enum UserDefaultsUserKey: String {
    case AppShared = "alreadyShared"

    case UserLocationApproximate = "isApproximateLocation"

    case ChatSafetyTipsShown = "chatSafetyTipsShown"
    case ChatDirectAnswersShow = "showDirectAnswers"

    case RatingAlreadyRated = "alreadyRated"
    case RatingRemindMeLaterDate = "remindMeLater"

    case PostProductLastGalleryAlbumSelected = "lastGalleryAlbumSelected"
    case PostProductLastTabSelected = "lastPostProductTabSelected"
    case PostProductPostedPreviously = "postProductPostedPreviously"

    case CommercializersPending = "pendingCommercializers"

    case TrackingProductSellComplete24hTracked = "trackingProductSellComplete24hTracked"

    case ShouldShowExpressChat = "shouldShowExpressChat"
    case ProductsWithExpressChatAlreadyShown = "productsWithExpressChatAlreadyShown"
    case ProductsWithExpressChatMessageSent = "productsWithExpressChatMessageSent"
    case MarketingNotifications = "marketingNotifications"
    case ProductsMarkAsFavorite = "productsMarkAsFavorite"
}


// MARK: > Dictionary helper

private extension Dictionary where Key: ExpressibleByStringLiteral, Value: AnyObject {
    func decode<T>(_ key: Key, defaultValue: T) -> T {
        return (self[key] as? T) ?? defaultValue
    }
    mutating func encode(_ key: Key, value: Value) {
        self[key] = value
    }
}
