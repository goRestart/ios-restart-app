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

    init(objectId: String?, createdAt: Date, isRead: Bool, type: NotificationType) {
        self.objectId = objectId
        self.createdAt = createdAt
        self.isRead = isRead
        self.type = type
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
        let result = curry(LGNotification.init)
            <^> j <|? "uuid"
            <*> j <| "created_at"
            <*> j <| "is_read"
            <*> NotificationType.decode(j)

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.Parsing, message: "LGNotification parse error: \(error)")
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
            result = curry(NotificationType.like)
                <^> LGNotificationProduct.decode(data)
                <*> LGNotificationUser.decode(data)
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
            result = curry(NotificationType.sold)
                <^> LGNotificationProduct.decode(data)
                <*> LGNotificationUser.decode(data)
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
            result = curry(NotificationType.rating)
                <^> LGNotificationUser.decode(data)
                <*> data <| JSONKeys.ratingValue
                <*> data <|? JSONKeys.comments
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
            result = curry(NotificationType.ratingUpdated)
                <^> LGNotificationUser.decode(data)
                <*> data <| JSONKeys.ratingValue
                <*> data <|? JSONKeys.comments
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
            result = curry(buildBuyersInterested)
                <^> LGNotificationProduct.decode(data)
                <*> data <|| JSONKeys.buyers
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
            result = curry(NotificationType.productSuggested)
                <^> LGNotificationProduct.decode(data)
                <*> LGNotificationUser.decode(data)
        default:
            return Decoded<NotificationType>.fromOptional(nil)
        }

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.Parsing, message: "NotificationType parse error: \(error)")
        }
        return result
    }

    private static func buildBuyersInterested(_ product: NotificationProduct, buyers: [LGNotificationUser]) -> NotificationType {
        return NotificationType.buyersInterested(product: product, buyers: buyers.flatMap({$0}))
    }
}
