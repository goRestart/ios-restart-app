//
//  PushNotification.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

enum PushNotification {
    case Home
    case Message(messageType: MessageType, data: ConversationData)
    case Scheme(uriScheme: UriScheme)

    static func buildFromLaunchOptions(launchOptions: [NSObject: AnyObject]) -> PushNotification? {
        guard let userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]
            as? [NSObject : AnyObject] else { return nil }
        return PushNotification.buildFromUserInfo(userInfo)
    }

    /**
     Uses the following parameters from user info:
        - "url": Url scheme type push notifications
        - "n_t": In Chat message related push, the messageType
        - "p"  : In Chat message related push, the productId
        - "b"  : In Chat message related push, the buyerId
        - "c"  : In Chat message related push, the conversationId

     */
    static func buildFromUserInfo(userInfo: [NSObject : AnyObject]) -> PushNotification? {
        if let urlStr = userInfo["url"] as? String, url = NSURL(string: urlStr), uriScheme = UriScheme.buildFromUrl(url) {
                return .Scheme(uriScheme: uriScheme)
        } else if let productId = userInfo["p"] as? String, let buyerId = userInfo["u"] as? String {
            let type = MessageType(rawValue: userInfo["n_t"]?.integerValue ?? 0 ) ?? .Message
            return .Message(messageType: type, data: .ProductBuyer(productId: productId, buyerId: buyerId))
        } else if let conversationId = userInfo["c"] as? String {
            let type = MessageType(rawValue: userInfo["n_t"]?.integerValue ?? 0 ) ?? .Message
            return .Message(messageType: type, data: .Conversation(conversationId: conversationId))
        }

        return nil
    }

    var deepLink: DeepLink {
        switch self {
        case .Home:
            return .Home
        case let .Message(messageType, data):
            return .Message(messageType: messageType, data: data)
        case let .Scheme(uriScheme):
            return uriScheme.deepLink
        }
    }
}
