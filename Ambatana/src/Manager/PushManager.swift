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

    func application(application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        // Setup push notification libraries
        setupLeanplum()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        /* If push notification alert was already shown, then call `registerForRemoteNotifications` again
         so the app delegate method will be called back again and update `Installation` (if needed) in:
         `application(application:didRegisterForRemoteNotificationsWithDeviceToken:) */
        if application.areRemoteNotificationsEnabled {
            application.registerForRemoteNotifications()
        } else {
            installationRepository.updatePushToken("", completion: nil)
        }
    }

    func application(application: UIApplication,
                            didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        DeepLinksRouter.sharedInstance.didReceiveRemoteNotification(userInfo,
                                                                    applicationState: application.applicationState)
    }

    func application(application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        installationRepository.updatePushToken(tokenStringFromData(deviceToken), completion: nil)
    }

    func application(application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        installationRepository.updatePushToken("", completion: nil)
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?,
                            forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        Leanplum.handleActionWithIdentifier(identifier, forRemoteNotification: userInfo, completionHandler: completionHandler)
    }

    func application(application: UIApplication,
                            didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NSNotificationCenter.defaultCenter()
            .postNotificationName(Notification.DidRegisterUserNotificationSettings.rawValue, object: nil)
        pushPermissionManager.application(application, didRegisterUserNotificationSettings: notificationSettings)
    }


    // MARK: - Private methods

    private func setupLeanplum() {
        Leanplum.setAppId(EnvironmentProxy.sharedInstance.leanplumAppId,
                              withDevelopmentKey:EnvironmentProxy.sharedInstance.leanplumEnvKey)
    }

    private func tokenStringFromData(data: NSData) -> String {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        return (data.description as NSString).stringByTrimmingCharactersInSet(characterSet)
            .stringByReplacingOccurrencesOfString(" ", withString: "") as String
    }
}
