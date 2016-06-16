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
    static let ratingShowProductListBannerDefaultValue = false
    static let postProductLastGalleryAlbumSelectedDefaultValue: String? = nil
    static let postProductLastTabSelectedDefaultValue = 1
    static let commercializersPendingDefaultValue = [String:[String]]()
    static let trackingProductSellComplete24hTrackedDefaultValue = false

    var appShared: Bool
    var userLocationApproximate: Bool
    var chatSafetyTipsShown: Bool
    var chatShowDirectAnswers: [String:Bool] // <id>: <value>
    var ratingAlreadyRated: Bool
    var ratingRemindMeLaterDate: NSDate?
    var ratingShowProductListBanner: Bool
    var postProductLastGalleryAlbumSelected: String?
    var postProductLastTabSelected: Int
    var commercializersPending: [String:[String]] // <id>: [<value>,...]
    var trackingProductSellComplete24hTracked: Bool

    init() {
        let appShared = UserDefaultsUser.appSharedDefaultValue
        let userLocationApproximate = UserDefaultsUser.userLocationApproximateDefaultValue
        let chatSafetyTipsShown = UserDefaultsUser.chatSafetyTipsShownDefaultValue
        let ratingAlreadyRated = UserDefaultsUser.ratingAlreadyRatedDefaultValue
        let ratingRemindMeLaterDate = UserDefaultsUser.ratingRemindMeLaterDateDefaultValue
        let ratingShowProductListBanner = UserDefaultsUser.ratingShowProductListBannerDefaultValue
        let chatShowDirectAnswers = UserDefaultsUser.chatShowDirectAnswersDefaultValue
        let postProductLastGalleryAlbumSelected = UserDefaultsUser.postProductLastGalleryAlbumSelectedDefaultValue
        let postProductLastTabSelected = UserDefaultsUser.postProductLastTabSelectedDefaultValue
        let commercializersPending = UserDefaultsUser.commercializersPendingDefaultValue
        let trackingProductSellComplete24hTracked = UserDefaultsUser.trackingProductSellComplete24hTrackedDefaultValue

        self.init(appShared: appShared, userLocationApproximate: userLocationApproximate,
                  chatSafetyTipsShown: chatSafetyTipsShown, ratingAlreadyRated: ratingAlreadyRated,
                  ratingRemindMeLaterDate: ratingRemindMeLaterDate,
                  ratingShowProductListBanner: ratingShowProductListBanner, chatShowDirectAnswers: chatShowDirectAnswers,
                  postProductLastGalleryAlbumSelected: postProductLastGalleryAlbumSelected,
                  postProductLastTabSelected: postProductLastTabSelected, commercializersPending: commercializersPending,
                  trackingProductSellComplete24hTracked: trackingProductSellComplete24hTracked)
    }

    init(appShared: Bool, userLocationApproximate: Bool, chatSafetyTipsShown: Bool, ratingAlreadyRated: Bool,
         ratingRemindMeLaterDate: NSDate?, ratingShowProductListBanner: Bool, chatShowDirectAnswers: [String: Bool],
         postProductLastGalleryAlbumSelected: String?, postProductLastTabSelected: Int,
         commercializersPending: [String:[String]], trackingProductSellComplete24hTracked: Bool) {
        self.appShared = appShared
        self.userLocationApproximate = userLocationApproximate
        self.chatSafetyTipsShown = chatSafetyTipsShown
        self.ratingAlreadyRated = ratingAlreadyRated
        self.ratingRemindMeLaterDate = ratingRemindMeLaterDate
        self.ratingShowProductListBanner = ratingShowProductListBanner
        self.chatShowDirectAnswers = chatShowDirectAnswers
        self.postProductLastGalleryAlbumSelected = postProductLastGalleryAlbumSelected
        self.postProductLastTabSelected = postProductLastTabSelected
        self.commercializersPending = commercializersPending
        self.trackingProductSellComplete24hTracked = trackingProductSellComplete24hTracked
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
        let ratingShowProductListBanner = dictionary.decode(UserDefaultsUserKey.RatingShowProductListBanner.rawValue,
                                                            defaultValue: UserDefaultsUser.ratingShowProductListBannerDefaultValue)
        let postProductLastGalleryAlbumSelected: String? = dictionary.decode(UserDefaultsUserKey.PostProductLastGalleryAlbumSelected.rawValue,
                                                                             defaultValue: UserDefaultsUser.postProductLastGalleryAlbumSelectedDefaultValue)
        let postProductLastTabSelected = dictionary.decode(UserDefaultsUserKey.PostProductLastTabSelected.rawValue,
                                                           defaultValue: UserDefaultsUser.postProductLastTabSelectedDefaultValue)
        let commercializersPending = dictionary.decode(UserDefaultsUserKey.CommercializersPending.rawValue,
                                                       defaultValue: UserDefaultsUser.commercializersPendingDefaultValue)
        let trackingProductSellComplete24hTracked = dictionary.decode(UserDefaultsUserKey.TrackingProductSellComplete24hTracked.rawValue,
                                                                      defaultValue: UserDefaultsUser.trackingProductSellComplete24hTrackedDefaultValue)

        return UserDefaultsUser(appShared: appShared, userLocationApproximate: userLocationApproximate,
                                chatSafetyTipsShown: chatSafetyTipsShown, ratingAlreadyRated: ratingAlreadyRated,
                                ratingRemindMeLaterDate: ratingRemindMeLaterDate,
                                ratingShowProductListBanner: ratingShowProductListBanner,
                                chatShowDirectAnswers: chatShowDirectAnswers,
                                postProductLastGalleryAlbumSelected: postProductLastGalleryAlbumSelected,
                                postProductLastTabSelected: postProductLastTabSelected,
                                commercializersPending: commercializersPending,
                                trackingProductSellComplete24hTracked: trackingProductSellComplete24hTracked)
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
        dict.encode(UserDefaultsUserKey.RatingShowProductListBanner.rawValue, value: ratingShowProductListBanner)
        if let postProductLastGalleryAlbumSelected = postProductLastGalleryAlbumSelected {
            dict.encode(UserDefaultsUserKey.PostProductLastGalleryAlbumSelected.rawValue, value: postProductLastGalleryAlbumSelected)
        }
        dict.encode(UserDefaultsUserKey.PostProductLastTabSelected.rawValue, value: postProductLastTabSelected)
        dict.encode(UserDefaultsUserKey.CommercializersPending.rawValue, value: commercializersPending)
        dict.encode(UserDefaultsUserKey.TrackingProductSellComplete24hTracked.rawValue, value: trackingProductSellComplete24hTracked)
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
    case RatingShowProductListBanner = "ratingShowProductListBanner"

    case PostProductLastGalleryAlbumSelected = "lastGalleryAlbumSelected"
    case PostProductLastTabSelected = "lastPostProductTabSelected"

    case CommercializersPending = "pendingCommercializers"

    case TrackingProductSellComplete24hTracked = "trackingProductSellComplete24hTracked"
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
