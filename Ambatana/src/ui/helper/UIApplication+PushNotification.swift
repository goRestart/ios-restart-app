//
//  UIApplication+PushNotification.swift
//  LetGo
//
//  Created by Albert Hernández López on 13/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension UIApplication {
    var areRemoteNotificationsEnabled: Bool {
        if respondsToSelector(#selector(currentUserNotificationSettings)) {
            return currentUserNotificationSettings()?.types.contains(UIUserNotificationType.Alert) ?? false
        } else {
            return isRegisteredForRemoteNotifications()
        }
    }
}
