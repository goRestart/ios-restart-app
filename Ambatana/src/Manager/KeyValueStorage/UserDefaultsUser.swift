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
    var commercializersPending: [String:[String]] // <id>: [<value>,...]


    init(appShared: Bool, userLocationApproximate: Bool, chatSafetyTipsShown: Bool, ratingAlreadyRated: Bool,
         ratingRemindMeLaterDate: NSDate?, chatShowDirectAnswers: [String: Bool],
         commercializersPending: [String:[String]]) {
        self.appShared = appShared
        self.userLocationApproximate = userLocationApproximate
        self.chatSafetyTipsShown = chatSafetyTipsShown
        self.ratingAlreadyRated = ratingAlreadyRated
        self.ratingRemindMeLaterDate = ratingRemindMeLaterDate
        self.chatShowDirectAnswers = chatShowDirectAnswers
        self.commercializersPending = commercializersPending
    }
}


// MARK: - UserDefaultsDecodable

extension UserDefaultsUser: UserDefaultsDecodable {
    static func decode(dictionary: [String: AnyObject]) -> UserDefaultsUser? {
        let appShared = dictionary.decode(.AppShared, defaultValue: false)
        let userLocationApproximate = dictionary.decode(.UserLocationApproximate, defaultValue: true)
        let chatSafetyTipsShown = dictionary.decode(.ChatSafetyTipsShown, defaultValue: false)
        let chatShowDirectAnswers = dictionary.decode(.ChatDirectAnswersShow, defaultValue: [String:Bool]())
        let ratingAlreadyRated = dictionary.decode(.RatingAlreadyRated, defaultValue: false)
        let ratingRemindMeLaterDate: NSDate? = dictionary.decode(.RatingRemindMeLaterDate, defaultValue: nil)
        let commercializersPending = dictionary.decode(.CommercializersPending, defaultValue: [String:[String]]())

        return UserDefaultsUser(appShared: appShared, userLocationApproximate: userLocationApproximate,
                                chatSafetyTipsShown: chatSafetyTipsShown, ratingAlreadyRated: ratingAlreadyRated,
                                ratingRemindMeLaterDate: ratingRemindMeLaterDate,
                                chatShowDirectAnswers: chatShowDirectAnswers,
                                commercializersPending: commercializersPending)
    }

    func encode() -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        dict.encode(.AppShared, value: appShared)
        dict.encode(.UserLocationApproximate, value: userLocationApproximate)
        dict.encode(.ChatSafetyTipsShown, value: chatSafetyTipsShown)
        dict.encode(.ChatDirectAnswersShow, value: chatShowDirectAnswers)
        dict.encode(.RatingAlreadyRated, value: ratingAlreadyRated)
        if let ratingRemindMeLaterDate = ratingRemindMeLaterDate {
            dict.encode(.RatingRemindMeLaterDate, value: ratingRemindMeLaterDate)
        }
        dict.encode(.CommercializersPending, value: commercializersPending)
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

    case CommercializersPending = "pendingCommercializers"
}


// MARK: > Dictionary helper

private extension Dictionary where Key: String, Value: AnyObject {
    func decode<T>(key: UserDefaultsUserKey, defaultValue: T) -> T {
        return (self[key.rawValue] as? T) ?? defaultValue
    }
    func encode(key: UserDefaultsUserKey, value: AnyObject) {
        self[key.rawValue] = value
    }
}
