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
    static let ratingRemindMeLaterDateDefaultValue: NSDate? = nil
    static let postProductLastGalleryAlbumSelectedDefaultValue: String? = nil
    static let postProductLastTabSelectedDefaultValue = 1
    static let postProductPostedPreviouslyDefaultValue = false
    static let commercializersPendingDefaultValue = [String:[String]]()
    static let trackingProductSellComplete24hTrackedDefaultValue = false
    static let shouldShowCommercializerAfterPostingDefaultValue = true
    static let shouldShowExpressChatDefaultValue = true
    static let productsWithExpressChatAlreadyShownDefaultValue: [String] = []

    var appShared: Bool
    var userLocationApproximate: Bool
    var chatSafetyTipsShown: Bool
    var chatShowDirectAnswers: [String:Bool] // <id>: <value>
    var ratingAlreadyRated: Bool
    var ratingRemindMeLaterDate: NSDate?
    var postProductLastGalleryAlbumSelected: String?
    var postProductLastTabSelected: Int
    var postProductPostedPreviously: Bool
    var commercializersPending: [String:[String]] // <id>: [<value>,...]
    var trackingProductSellComplete24hTracked: Bool
    var shouldShowCommercializerAfterPosting: Bool
    var shouldShowExpressChat: Bool
    var productsWithExpressChatAlreadyShown: [String]

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
        let shouldShowCommercializerAfterPosting = UserDefaultsUser.shouldShowCommercializerAfterPostingDefaultValue
        let shouldShowExpressChat = UserDefaultsUser.shouldShowExpressChatDefaultValue
        let productsWithExpressChatAlreadyShown = UserDefaultsUser.productsWithExpressChatAlreadyShownDefaultValue

        self.init(appShared: appShared, userLocationApproximate: userLocationApproximate,
                  chatSafetyTipsShown: chatSafetyTipsShown, ratingAlreadyRated: ratingAlreadyRated,
                  ratingRemindMeLaterDate: ratingRemindMeLaterDate, chatShowDirectAnswers: chatShowDirectAnswers,
                  postProductLastGalleryAlbumSelected: postProductLastGalleryAlbumSelected,
                  postProductLastTabSelected: postProductLastTabSelected, postProductPostedPreviously: postProductPostedPreviously,
                  commercializersPending: commercializersPending,
                  trackingProductSellComplete24hTracked: trackingProductSellComplete24hTracked,
                  shouldShowCommercializerAfterPosting: shouldShowCommercializerAfterPosting,
                  shouldShowExpressChat: shouldShowExpressChat,
                  productsWithExpressChatAlreadyShown: productsWithExpressChatAlreadyShown)
    }

    init(appShared: Bool, userLocationApproximate: Bool, chatSafetyTipsShown: Bool, ratingAlreadyRated: Bool,
         ratingRemindMeLaterDate: NSDate?, chatShowDirectAnswers: [String: Bool],
         postProductLastGalleryAlbumSelected: String?, postProductLastTabSelected: Int, postProductPostedPreviously: Bool,
         commercializersPending: [String:[String]], trackingProductSellComplete24hTracked: Bool,
         shouldShowCommercializerAfterPosting: Bool, shouldShowExpressChat: Bool, productsWithExpressChatAlreadyShown: [String]) {
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
        self.shouldShowCommercializerAfterPosting = shouldShowCommercializerAfterPosting
        self.shouldShowExpressChat = shouldShowExpressChat
        self.productsWithExpressChatAlreadyShown = productsWithExpressChatAlreadyShown
    }
}


// MARK: - UserDefaultsDecodable

extension UserDefaultsUser: UserDefaultsDecodable {
    static func decode(dictionary: [String: AnyObject]) -> UserDefaultsUser? {
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
        let ratingRemindMeLaterDate: NSDate? = dictionary.decode(UserDefaultsUserKey.RatingRemindMeLaterDate.rawValue,
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
        
        let shouldShowCommercializerAfterPosting = dictionary.decode(UserDefaultsUserKey.ShouldShowCommercializerAfterPosting.rawValue,
                                                                     defaultValue: UserDefaultsUser.shouldShowCommercializerAfterPostingDefaultValue)
        let shouldShowExpressChat = dictionary.decode(UserDefaultsUserKey.ShouldShowExpressChat.rawValue, defaultValue: UserDefaultsUser.shouldShowExpressChatDefaultValue)
        let productsWithExpressChatAlreadyShown = dictionary.decode(UserDefaultsUserKey.ProductsWithExpressChatAlreadyShown.rawValue, defaultValue: UserDefaultsUser.productsWithExpressChatAlreadyShownDefaultValue)
        return UserDefaultsUser(appShared: appShared, userLocationApproximate: userLocationApproximate,
                                chatSafetyTipsShown: chatSafetyTipsShown, ratingAlreadyRated: ratingAlreadyRated,
                                ratingRemindMeLaterDate: ratingRemindMeLaterDate,
                                chatShowDirectAnswers: chatShowDirectAnswers,
                                postProductLastGalleryAlbumSelected: postProductLastGalleryAlbumSelected,
                                postProductLastTabSelected: postProductLastTabSelected,
                                postProductPostedPreviously:  postProductPostedPreviously,
                                commercializersPending: commercializersPending,
                                trackingProductSellComplete24hTracked: trackingProductSellComplete24hTracked,
                                shouldShowCommercializerAfterPosting: shouldShowCommercializerAfterPosting,
                                shouldShowExpressChat: shouldShowExpressChat,
                                productsWithExpressChatAlreadyShown: productsWithExpressChatAlreadyShown)
    }

    func encode() -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        dict.encode(UserDefaultsUserKey.AppShared.rawValue, value: appShared)
        dict.encode(UserDefaultsUserKey.UserLocationApproximate.rawValue, value: userLocationApproximate)
        dict.encode(UserDefaultsUserKey.ChatSafetyTipsShown.rawValue, value: chatSafetyTipsShown)
        dict.encode(UserDefaultsUserKey.ChatDirectAnswersShow.rawValue, value: chatShowDirectAnswers)
        dict.encode(UserDefaultsUserKey.RatingAlreadyRated.rawValue, value: ratingAlreadyRated)
        if let ratingRemindMeLaterDate = ratingRemindMeLaterDate {
            dict.encode(UserDefaultsUserKey.RatingRemindMeLaterDate.rawValue, value: ratingRemindMeLaterDate)
        }
        dict.encode(UserDefaultsUserKey.RatingAlreadyRated.rawValue, value: ratingAlreadyRated)
        if let postProductLastGalleryAlbumSelected = postProductLastGalleryAlbumSelected {
            dict.encode(UserDefaultsUserKey.PostProductLastGalleryAlbumSelected.rawValue, value: postProductLastGalleryAlbumSelected)
        }
        dict.encode(UserDefaultsUserKey.PostProductLastTabSelected.rawValue, value: postProductLastTabSelected)
        dict.encode(UserDefaultsUserKey.PostProductPostedPreviously.rawValue, value: postProductPostedPreviously)
        dict.encode(UserDefaultsUserKey.CommercializersPending.rawValue, value: commercializersPending)
        dict.encode(UserDefaultsUserKey.TrackingProductSellComplete24hTracked.rawValue, value: trackingProductSellComplete24hTracked)
        dict.encode(UserDefaultsUserKey.ShouldShowCommercializerAfterPosting.rawValue, value: shouldShowCommercializerAfterPosting)
        dict.encode(UserDefaultsUserKey.ShouldShowExpressChat.rawValue, value: shouldShowExpressChat)
        dict.encode(UserDefaultsUserKey.ProductsWithExpressChatAlreadyShown.rawValue, value: productsWithExpressChatAlreadyShown)
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
    
    case ShouldShowCommercializerAfterPosting = "shouldShowCommercializerAfterPosting"

    case ShouldShowExpressChat = "shouldShowExpressChat"
    case ProductsWithExpressChatAlreadyShown = "productsWithExpressChatAlreadyShown"
}


// MARK: > Dictionary helper

private extension Dictionary where Key: StringLiteralConvertible, Value: AnyObject {
    func decode<T>(key: Key, defaultValue: T) -> T {
        return (self[key] as? T) ?? defaultValue
    }
    mutating func encode(key: Key, value: Value) {
        self[key] = value
    }
}
