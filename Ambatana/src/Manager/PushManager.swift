//
//  PushManager.swift
//  LetGo
//
//  Created by Albert Hernández López on 28/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Leanplum

final class PushManager {
    enum Notification: String {
        case DidRegisterUserNotificationSettings
    }

    static let sharedInstance: PushManager = PushManager()

    private let pushPermissionManager: PushPermissionsManager
    private let installationRepository: InstallationRepository


    // MARK: - Lifecycle

    convenience init() {
        let pushPermissionManager = PushPermissionsManager.sharedInstance
        let installationRepository = Core.installationRepository
        self.init(pushPermissionManager: pushPermissionManager, installationRepository: installationRepository)
    }

    required init(pushPermissionManager: PushPermissionsManager, installationRepository: InstallationRepository) {
        self.pushPermissionManager = pushPermissionManager
        self.installationRepository = installationRepository
    }


    // MARK: - Internal methods

    func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) {
        // Setup push notification libraries
        setupLeanplum()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        /* If push notification alert was already shown, then call `registerForRemoteNotifications` again
         so the app delegate method will be called back again and update `Installation` (if needed) in:
         `application(application:didRegisterForRemoteNotificationsWithDeviceToken:) */
        if application.areRemoteNotificationsEnabled {
            application.registerForRemoteNotifications()
        } else {
            installationRepository.updatePushToken("", completion: nil)
        }
    }

    func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        DeepLinksRouter.sharedInstance.didReceiveRemoteNotification(userInfo,
                                                                    applicationState: application.applicationState)
    }

    func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        installationRepository.updatePushToken(tokenStringFromData(deviceToken), completion: nil)
    }

    func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
        installationRepository.updatePushToken("", completion: nil)
    }

    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?,
                            forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        Leanplum.handleAction(withIdentifier: identifier, forRemoteNotification: userInfo, completionHandler: completionHandler)
    }

    func application(_ application: UIApplication,
                            didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NotificationCenter.default
            .post(name: Foundation.Notification.Name(rawValue: Notification.DidRegisterUserNotificationSettings.rawValue), object: nil)
        pushPermissionManager.application(application, didRegisterUserNotificationSettings: notificationSettings)
    }


    // MARK: - Private methods

    private func setupLeanplum() {
        Leanplum.setAppId(EnvironmentProxy.sharedInstance.leanplumAppId,
                              withDevelopmentKey:EnvironmentProxy.sharedInstance.leanplumEnvKey)
    }

    private func tokenStringFromData(_ data: Data) -> String {
        let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
        return (data.description as NSString).trimmingCharacters(in: characterSet)
            .replacingOccurrences(of: " ", with: "") as String
    }
}
