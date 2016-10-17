//
//  PushManager.swift
//  LetGo
//
//  Created by Albert Hernández López on 28/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Kahuna
import Leanplum

final class PushManager: NSObject, KahunaDelegate {
    enum Notification: String {
        case DidRegisterUserNotificationSettings
    }

    static let sharedInstance: PushManager = PushManager()

    private let pushPermissionManager: PushPermissionsManager
    private let installationRepository: InstallationRepository


    // MARK: - Lifecycle

    convenience override init() {
        let pushPermissionManager = PushPermissionsManager.sharedInstance
        let installationRepository = Core.installationRepository
        self.init(pushPermissionManager: pushPermissionManager, installationRepository: installationRepository)
    }

    required init(pushPermissionManager: PushPermissionsManager, installationRepository: InstallationRepository) {
        self.pushPermissionManager = pushPermissionManager
        self.installationRepository = installationRepository
        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PushManager.login(_:)),
                                                         name: SessionManager.Notification.Login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PushManager.logout(_:)),
                                                         name: SessionManager.Notification.Logout.rawValue, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    // MARK: - Internal methods

    func application(application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        // Setup push notification libraries
        setupKahuna()
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
        Kahuna.handleNotification(userInfo, withApplicationState: application.applicationState)
        DeepLinksRouter.sharedInstance.didReceiveRemoteNotification(userInfo,
                                                                    applicationState: application.applicationState)
    }

    func application(application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        installationRepository.updatePushToken(tokenStringFromData(deviceToken), completion: nil)
        Kahuna.setDeviceToken(deviceToken)
    }

    func application(application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        installationRepository.updatePushToken("", completion: nil)
        Kahuna.handleNotificationRegistrationFailure(error)
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?,
                            forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        Leanplum.handleActionWithIdentifier(identifier, forRemoteNotification: userInfo, completionHandler: completionHandler)
        Kahuna.handleNotification(userInfo, withActionIdentifier: identifier,
                                  withApplicationState: UIApplication.sharedApplication().applicationState)
    }

    func application(application: UIApplication,
                            didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NSNotificationCenter.defaultCenter()
            .postNotificationName(Notification.DidRegisterUserNotificationSettings.rawValue, object: nil)
        PushPermissionsManager.sharedInstance.application(application,
                                                          didRegisterUserNotificationSettings: notificationSettings)
    }


    // MARK: - Private methods

    private func setupKahuna() {
        Kahuna.launchWithKey(EnvironmentProxy.sharedInstance.kahunaAPIKey)
    }

    private func setupLeanplum() {
        let environmentHelper = EnvironmentsHelper()
        switch environmentHelper.appEnvironment {
        case .Production:
            Leanplum.setAppId(EnvironmentProxy.sharedInstance.leanplumAppId,
                              withProductionKey: EnvironmentProxy.sharedInstance.leanplumEnvKey)
        case .Development:
            Leanplum.setAppId(EnvironmentProxy.sharedInstance.leanplumAppId,
                              withDevelopmentKey:EnvironmentProxy.sharedInstance.leanplumEnvKey)
        }
    }

    dynamic private func login(notification: NSNotification) {
        guard let user = Core.myUserRepository.myUser else { return }

        let uc = Kahuna.createUserCredentials()
        var loginError: NSError?
        if let userId = user.objectId {
            uc.addCredential(KAHUNA_CREDENTIAL_USER_ID, withValue: userId)
        }
        if let email = user.email {
            uc.addCredential(KAHUNA_CREDENTIAL_EMAIL, withValue: email)
        }
        Kahuna.loginWithCredentials(uc, error: &loginError)
        if (loginError != nil) {
            print("Login Error : \(loginError!.localizedDescription)")
        }
    }
    
    dynamic private func logout(notification: NSNotification) {
        Kahuna.logout()
    }

    private func tokenStringFromData(data: NSData) -> String {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        return (data.description as NSString).stringByTrimmingCharactersInSet(characterSet)
            .stringByReplacingOccurrencesOfString(" ", withString: "") as String
    }
}
