//
//  LGNotification.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGNotification: NotificationModel {
    let objectId: String?
    let createdAt: Date
    let isRead: Bool
    let type: NotificationType
    let campaignType: String?

    init(objectId: String?, createdAt: Date, isRead: Bool, type: NotificationType, campaignType: String?) {
        self.objectId = objectId
        self.createdAt = createdAt
        self.isRead = isRead
        self.type = type
        self.campaignType = campaignType
    }
}

extension LGNotification : Decodable {

    /**
     Expects a json in the form:
     {
         "type": "Like/Follow/Sold",
         "uuid": "73aedba9-11db-3207-bb47-26812bfe8e71",
         "created_at": 1461569433,
         "is_read": false,
         "data" : {... type concrete data ...}
     }
     */
    static func decode(_ j: JSON) -> Decoded<LGNotification> {
        let result1 = curry(LGNotification.init)
        let result2 = result1 <^> j <|? "uuid"
        let result3 = result2 <*> j <| "created_at"
        let result4 = result3 <*> j <| "is_read"
        let result5 = result4 <*> NotificationType.decode(j)
        let result  = result5 <*> j <|? "campaign_type"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGNotification parse error: \(error)")
        }
        return result
    }
}


extension NotificationType: Decodable {
    private struct JSONKeys {
        static let buyers = "buyers"
        static let ratingValue = "rating_value"
        static let comments = "comments"
    }

    public static func decode(_ j: JSON) -> Decoded<NotificationType> {
        guard let type: String = j.decode("type") else { return Decoded<NotificationType>.fromOptional(nil) }
        guard let data: JSON = j.decode("data") else { return Decoded<NotificationType>.fromOptional(nil) }

        let result: Decoded<NotificationType>
        switch type {
        case "like":
            /**
             "data" : {
                 "product_id": "a569527f-17e2-3d22-a513-2fc0c6477ac8",
                 "product_image": "Ms.",
                 "product_title": "Miss",
                 "user_id": "3ba8869d-4d19-3b24-922f-5e2d61095bf3",
                 "user_image": "Miss",
                 "username": "Prof."
             }
             */
            let result1 = curry(NotificationType.makeLike)
            let result2 = result1 <^> LGNotificationListing.decode(data)
            result      = result2 <*> LGNotificationUser.decode(data)
        case "sold":
            /**
             "data" : {
                 "product_id": "a569527f-17e2-3d22-a513-2fc0c6477ac8",
                 "product_image": "Ms.",
                 "product_title": "Miss",
                 "user_id": "3ba8869d-4d19-3b24-922f-5e2d61095bf3",
                 "user_image": "Miss",
                 "username": "Prof."
             }
             */
            let result1 = curry(NotificationType.makeSold)
            let result2 = result1 <^> LGNotificationListing.decode(data)
            result      = result2 <*> LGNotificationUser.decode(data)
        case "review":
            /**
             "data" : {
                 "user_id": "3ba8869d-4d19-3b24-922f-5e2d61095bf3",
                 "user_image": "Miss",
                 "username": "Prof.",
                 "rating_value" : 4,
                 "comments": "Super!"
             }
             */
            let result1 = curry(NotificationType.makeRating)
            let result2 = result1 <^> LGNotificationUser.decode(data)
            let result3 = result2 <*> data <| JSONKeys.ratingValue
            result      = result3 <*> data <|? JSONKeys.comments
        case "review_updated":
            /**
             "data" : {
                 "user_id": "3ba8869d-4d19-3b24-922f-5e2d61095bf3",
                 "user_image": "Miss",
                 "username": "Prof.",
                 "rating_value" : 4,
                 "comments": "Super!"
             }
             */
            let result1 = curry(NotificationType.makeRatingUpdated)
            let result2 = result1 <^> LGNotificationUser.decode(data)
            let result3 = result2 <*> data <| JSONKeys.ratingValue
            result      = result3 <*> data <|? JSONKeys.comments
        case "buyers_interested":
            /*
             "data": {
                "product_id": "51be9a62-9b7a-43ab-9401-7bbd5c360f1d",
                "product_title": "aut",
                "product_image": "http://cdn.letgo.com/images\/ba\/16\/08\/b4\/c3b3200dee3a8fd0906680fd255779a6.jpg",
                "buyers": [{
                    "user_id": "4352e516-e098-4b06-83d8-892ca9621c33",
                    "username": "Counting Crows",
                    "user_image": "https://s3.amazonaws.com/letgo-avatars-pro/images/abbc9384-9790-4bbb-9db2-1c3522889e96\/tfss-18b35ad8-5d50-4a5c-bec3-aef7174b31d2-W2Zf69six7.jpg"
                },...]
             }
             */
            let result1 = curry(NotificationType.makeBuyersInterested)
            let result2 = result1 <^> LGNotificationListing.decode(data)
            result      = result2 <*> data <|| JSONKeys.buyers
        case "product_suggested":
            /*
             "data": {
                "user_id": "4352e516-e098-4b06-83d8-892ca9621c33",
                "username": "Counting Crows",
                "user_image": "https://s3.amazonaws.com/letgo-avatars-pro/images/abbc9384-9790-4bbb-9db2-1c3522889e96\/tfss-18b35ad8-5d50-4a5c-bec3-aef7174b31d2-W2Zf69six7.jpg",
                "product_id": "51be9a62-9b7a-43ab-9401-7bbd5c360f1d",
                "product_title": "aut",
                "product_image": "http://cdn.letgo.com/images\/ba\/16\/08\/b4\/c3b3200dee3a8fd0906680fd255779a6.jpg"
             }
            */
            let result1 = curry(NotificationType.makeProductSuggested)
            let result2 = result1 <^> LGNotificationListing.decode(data)
            result      = result2 <*> LGNotificationUser.decode(data)
        case "facebook_friendship_created":
            /*
             "data": {
                "user_id": "06820d78-a604-4acb-8f2e-21348b221876",
                "username": "Letgo Chuck Norris",
                "facebook_username": "Facebook Chuck Norris",
                "user_image": "http://cdn.letgo.com/images\/ba\/16\/08\/b4\/c3b3200dee3a8fd0906680fd255779a6.jpg"
             }
            */
            let result1 = curry(NotificationType.makeFacebookFriendshipCreated)
            let result2 = result1 <^> LGNotificationUser.decode(data)
            result      = result2 <*> data <| "facebook_username"
        case "modular":
            let result1 = curry(NotificationType.makeModular)
            result      = result1 <^> LGNotificationModular.decode(data)
        default:
            return Decoded<NotificationType>.fromOptional(nil)
        }

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "NotificationType parse error: \(error)")
        }
        return result
    }
}

fileprivate extension NotificationType {
    static func makeLike(product: LGNotificationListing,
                         user: LGNotificationUser) -> NotificationType {
        return .like(product: product,
                     user: user)
    }
    
    static func makeSold(product: LGNotificationListing,
                         user: LGNotificationUser) -> NotificationType {
        return .sold(product: product,
                     user: user)
    }
    
    static func makeRating(user: LGNotificationUser,
                           value: Int,
                           comments: String?) -> NotificationType {
        return .rating(user: user,
                       value: value,
                       comments: comments)
    }
    
    static func makeRatingUpdated(user: LGNotificationUser,
                                  value: Int,
                                  comments: String?) -> NotificationType {
        return .ratingUpdated(user: user,
                              value: value,
                              comments: comments)
    }
    
    static func makeBuyersInterested(product: LGNotificationListing,
                                     buyers: [LGNotificationUser]) -> NotificationType {
        return .buyersInterested(product: product,
                                 buyers: buyers)
    }
    
    static func makeProductSuggested(product: LGNotificationListing,
                                     seller: LGNotificationUser) -> NotificationType {
        return .productSuggested(product: product,
                                 seller: seller)
    }
    
    static func makeFacebookFriendshipCreated(user: LGNotificationUser,
                                              facebookUsername: String) -> NotificationType {
        return .facebookFriendshipCreated(user: user,
                                          facebookUsername: facebookUsername)
    }
    
    static func makeModular(modules: LGNotificationModular) -> NotificationType {
        return .modular(modules: modules)
    }
}
