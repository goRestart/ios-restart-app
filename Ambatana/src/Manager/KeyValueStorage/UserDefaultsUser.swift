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
    var appShared: Bool
    var userLocationApproximate: Bool
    var chatSafetyTipsShown: Bool
    var chatShowDirectAnswers: [String:Bool] // <id>: <value>
    var ratingAlreadyRated: Bool
    var ratingRemindMeLaterDate: NSDate?
    var postProductLastGalleryAlbumSelected: String?
    var postProductLastTabSelected: Int
    var commercializersPending: [String:[String]] // <id>: [<value>,...]

    init() {
        self.init(appShared: false, userLocationApproximate: true, chatSafetyTipsShown: false, ratingAlreadyRated: false,
                  ratingRemindMeLaterDate: nil, chatShowDirectAnswers: [String: Bool](),
                  postProductLastGalleryAlbumSelected: nil, postProductLastTabSelected: 0,
                  commercializersPending: [String:[String]]())
    }

    init(appShared: Bool, userLocationApproximate: Bool, chatSafetyTipsShown: Bool, ratingAlreadyRated: Bool,
         ratingRemindMeLaterDate: NSDate?, chatShowDirectAnswers: [String: Bool],
         postProductLastGalleryAlbumSelected: String?, postProductLastTabSelected: Int,
         commercializersPending: [String:[String]]) {
        self.appShared = appShared
        self.userLocationApproximate = userLocationApproximate
        self.chatSafetyTipsShown = chatSafetyTipsShown
        self.ratingAlreadyRated = ratingAlreadyRated
        self.ratingRemindMeLaterDate = ratingRemindMeLaterDate
        self.chatShowDirectAnswers = chatShowDirectAnswers
        self.postProductLastGalleryAlbumSelected = postProductLastGalleryAlbumSelected
        self.postProductLastTabSelected = postProductLastTabSelected
        self.commercializersPending = commercializersPending
    }
}


// MARK: - UserDefaultsDecodable

extension UserDefaultsUser: UserDefaultsDecodable {
    static func decode(dictionary: [String: AnyObject]) -> UserDefaultsUser? {
        let appShared = dictionary.decode(UserDefaultsUserKey.AppShared.rawValue, defaultValue: false)
        let userLocationApproximate = dictionary.decode(UserDefaultsUserKey.UserLocationApproximate.rawValue, defaultValue: true)
        let chatSafetyTipsShown = dictionary.decode(UserDefaultsUserKey.ChatSafetyTipsShown.rawValue, defaultValue: false)
        let chatShowDirectAnswers = dictionary.decode(UserDefaultsUserKey.ChatDirectAnswersShow.rawValue, defaultValue: [String:Bool]())
        let ratingAlreadyRated = dictionary.decode(UserDefaultsUserKey.RatingAlreadyRated.rawValue, defaultValue: false)
        let ratingRemindMeLaterDate: NSDate? = dictionary.decode(UserDefaultsUserKey.RatingRemindMeLaterDate.rawValue, defaultValue: nil)
        let postProductLastGalleryAlbumSelected: String? = dictionary.decode(UserDefaultsUserKey.PostProductLastGalleryAlbumSelected.rawValue,
                                                                             defaultValue: nil)
        let postProductLastTabSelected = dictionary.decode(UserDefaultsUserKey.PostProductLastTabSelected.rawValue, defaultValue: 0)
        let commercializersPending = dictionary.decode(UserDefaultsUserKey.CommercializersPending.rawValue, defaultValue: [String:[String]]())

        return UserDefaultsUser(appShared: appShared, userLocationApproximate: userLocationApproximate,
                                chatSafetyTipsShown: chatSafetyTipsShown, ratingAlreadyRated: ratingAlreadyRated,
                                ratingRemindMeLaterDate: ratingRemindMeLaterDate,
                                chatShowDirectAnswers: chatShowDirectAnswers,
                                postProductLastGalleryAlbumSelected: postProductLastGalleryAlbumSelected,
                                postProductLastTabSelected: postProductLastTabSelected,
                                commercializersPending: commercializersPending)
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
            dict.encode(UserDefaultsUserKey.PostProductLastTabSelected.rawValue, value: postProductLastGalleryAlbumSelected)
        }
        dict.encode(UserDefaultsUserKey.PostProductLastTabSelected.rawValue, value: postProductLastTabSelected)
        dict.encode(UserDefaultsUserKey.CommercializersPending.rawValue, value: commercializersPending)
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

    case CommercializersPending = "pendingCommercializers"
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
