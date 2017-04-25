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

    static func buildFromLaunchOptions(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]) -> PushNotification? {
        guard let userInfo = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification]
            as? [AnyHashable: Any] else { return nil }
        return PushNotification.buildFromUserInfo(userInfo, appActive: false)
    }

    /**
     Gets the badge number and uses the following parameters from user info:
        - "url": Url scheme type push notifications
        - "n_t": In Chat message related push, the messageType
        - "p"  : In Chat message related push, the productId
        - "u"  : In Chat message related push, the buyerId
        - "c"  : In Chat message related push, the conversationId
     */
    static func buildFromUserInfo(_ userInfo: [AnyHashable: Any], appActive: Bool) -> PushNotification? {

        let badge = getBadgeNumberFromUserInfo(userInfo)
        let alert = getAlertFromUserInfo(userInfo) ?? ""
        let origin = DeepLinkOrigin.push(appActive: appActive, alert: alert)
        
        if let urlStr = userInfo["url"] as? String, let url = URL(string: urlStr), let uriScheme = UriScheme.buildFromUrl(url) {

            return PushNotification(deepLink: DeepLink.push(uriScheme.deepLink.action, origin: origin,
                campaign: uriScheme.deepLink.campaign, medium: uriScheme.deepLink.medium,
                source: uriScheme.deepLink.source, cardActionParameter: uriScheme.deepLink.cardActionParameter), badge: badge)

        } else if let conversationId = userInfo["c"] as? String {
            let type = DeepLinkMessageType(rawValue: (userInfo["n_t"] as? Int) ?? 0 ) ?? .message
            return PushNotification(deepLink: DeepLink.push(.message(messageType: type, data:
                .conversation(conversationId: conversationId)), origin: origin, campaign: nil, medium: nil,
                source: .push, cardActionParameter: nil), badge: badge)

        } else if let productId = userInfo["p"] as? String, let buyerId = userInfo["u"] as? String {
            
            let type = DeepLinkMessageType(rawValue: (userInfo["n_t"] as? Int) ?? 0 ) ?? .message
            return PushNotification(deepLink: DeepLink.push(.message(messageType: type, data:
                .productBuyer(productId: productId, buyerId: buyerId)), origin: origin, campaign: nil, medium: nil,
                source: .push, cardActionParameter: nil), badge: badge)
        }

        return nil
    }

    private static func getBadgeNumberFromUserInfo(_ userInfo: [AnyHashable: Any]) -> Int? {
        if let newBadge = userInfo["badge"] as? Int {
            return newBadge
        } else if let aps = userInfo["aps"] as? [AnyHashable: Any] {
            return self.getBadgeNumberFromUserInfo(aps)
        } else {
            return nil
        }
    }

    private static func getAlertFromUserInfo(_ userInfo: [AnyHashable: Any]) -> String? {
        if let alert = userInfo["alert"] as? String {
            return alert
        } else if let aps = userInfo["aps"] as? [AnyHashable: Any] {
            return self.getAlertFromUserInfo(aps)
        } else {
            return nil
        }
    }
}
