//
//  PushNotification.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

struct PushNotification {

    let deepLink: DeepLink
    let badge: Int?

    static func buildFromLaunchOptions(launchOptions: [NSObject: AnyObject]) -> PushNotification? {
        guard let userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]
            as? [NSObject : AnyObject] else { return nil }
        return PushNotification.buildFromUserInfo(userInfo)
    }

    /**
     Gets the badge number and uses the following parameters from user info:
        - "url": Url scheme type push notifications
        - "n_t": In Chat message related push, the messageType
        - "p"  : In Chat message related push, the productId
        - "b"  : In Chat message related push, the buyerId
        - "c"  : In Chat message related push, the conversationId
     */
    static func buildFromUserInfo(userInfo: [NSObject : AnyObject]) -> PushNotification? {

        let badge = getBadgeNumberFromUserInfo(userInfo)

        if let urlStr = userInfo["url"] as? String, url = NSURL(string: urlStr), uriScheme = UriScheme.buildFromUrl(url) {
            return PushNotification(deepLink: uriScheme.deepLink, badge: badge)
        } else if let productId = userInfo["p"] as? String, let buyerId = userInfo["u"] as? String {
            let type = MessageType(rawValue: userInfo["n_t"]?.integerValue ?? 0 ) ?? .Message
            return PushNotification(deepLink: .Message(messageType: type, data:
                .ProductBuyer(productId: productId, buyerId: buyerId)), badge: badge)
        } else if let conversationId = userInfo["c"] as? String {
            let type = MessageType(rawValue: userInfo["n_t"]?.integerValue ?? 0 ) ?? .Message
            return PushNotification(deepLink: .Message(messageType: type, data:
                .Conversation(conversationId: conversationId)), badge: badge)
        }

        return nil
    }

    private static func getBadgeNumberFromUserInfo(userInfo: [NSObject: AnyObject]) -> Int? {
        if let newBadge = userInfo["badge"] as? Int {
            return newBadge
        } else if let aps = userInfo["aps"] as? [NSObject: AnyObject] {
            return self.getBadgeNumberFromUserInfo(aps)
        } else {
            return nil
        }
    }
}
