//
//  UIApplication+PushNotification.swift
//  LetGo
//
//  Created by Albert Hernández López on 13/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UserNotifications

extension UIApplication {

    func registerPushNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.currentNotificationCenter()
            center.requestAuthorizationWithOptions([.Badge, .Sound, .Alert], completionHandler: { (granted, error) in
                guard granted else { return }
                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    guard let strongSelf = self else { return }
                    let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
                    PushManager.sharedInstance.application(strongSelf, didRegisterUserNotificationSettings: settings)
                }
            })
        } else {
            let userNotificationTypes: UIUserNotificationType = ([.Alert, .Badge, .Sound])
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            registerUserNotificationSettings(settings)
        }
        registerForRemoteNotifications()
    }

    var areRemoteNotificationsEnabled: Bool {
        if respondsToSelector(#selector(currentUserNotificationSettings)) {
            return currentUserNotificationSettings()?.types.contains(UIUserNotificationType.Alert) ?? false
        } else {
            return isRegisteredForRemoteNotifications()
        }
    }
}
