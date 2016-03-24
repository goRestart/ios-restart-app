//
//  PushNotification.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum PushNotification {
    case Home

    static func buildFromLaunchOptions(launchOptions: [NSObject: AnyObject]) -> PushNotification? {
        guard let userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]
            as? [NSObject : AnyObject] else { return nil }
        return PushNotification.buildFromUserInfo(userInfo)
    }

    static func buildFromUserInfo(userInfo: [NSObject : AnyObject]) -> PushNotification? {
        return nil
    }

    var deepLink: DeepLink {
        switch self {
        case .Home:
            return .Home
        }
    }
}
