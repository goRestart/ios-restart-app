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
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
                guard granted else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
                    PushManager.sharedInstance.application(strongSelf, didRegisterUserNotificationSettings: settings)
                }
            })
        } else {
            let userNotificationTypes: UIUserNotificationType = ([.alert, .badge, .sound])
            let settings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
            registerUserNotificationSettings(settings)
        }
        registerForRemoteNotifications()
    }

    var areRemoteNotificationsEnabled: Bool {
        if responds(to: #selector(getter: currentUserNotificationSettings)) {
            return currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert) ?? false
        } else {
            return isRegisteredForRemoteNotifications
        }
    }
}
