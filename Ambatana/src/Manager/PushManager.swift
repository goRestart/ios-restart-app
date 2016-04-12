//
//  PushManager.swift
//  LetGo
//
//  Created by Albert Hernández López on 28/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import Kahuna
import RxSwift

public class PushManager: NSObject, KahunaDelegate {

    // Constants & enum
    enum Notification: String {
        case UnreadMessagesDidChange
        case DidRegisterUserNotificationSettings
    }

    // Singleton
    public static let sharedInstance: PushManager = PushManager()

    // Services
    private var installationRepository: InstallationRepository
    
    // iVars
    let unreadMessagesCount = Variable<Int>(0)

    // MARK: - Lifecycle

    public required init(installationRepository: InstallationRepository) {
        self.installationRepository = installationRepository
        unreadMessagesCount.value = 0
        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PushManager.login(_:)),
            name: SessionManager.Notification.Login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PushManager.logout(_:)),
            name: SessionManager.Notification.Logout.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PushManager.applicationWillEnterForeground(_:)),
            name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    public convenience override init() {
        let installationRepository = Core.installationRepository
        self.init(installationRepository: installationRepository)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    // MARK: - Public methods

    public func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {

            // Setup push notification libraries
            setupKahuna()
    }

    public func application(application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {

            Kahuna.handleNotification(userInfo, withApplicationState: UIApplication.sharedApplication().applicationState)

            guard let pushNotification = DeepLinksRouter.sharedInstance.didReceiveRemoteNotification(userInfo) else {
                return
            }

            UIApplication.sharedApplication().applicationIconBadgeNumber = pushNotification.badge ?? 0

            switch pushNotification.deepLink {
            case .Conversation, .Conversations, .Message:
                 //TODO is ok to handle updateUnreadMessagesCount or we should move it to tabBarCtrl? or somewhere else?
                updateUnreadMessagesCount()
            default: break
            }

    }

    public func application(application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
            installationRepository.updatePushToken(tokenStringFromData(deviceToken), completion: nil)
            Kahuna.setDeviceToken(deviceToken)
    }

    public func application(application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: NSError) {
            Kahuna.handleNotificationRegistrationFailure(error)
    }

    public func application(application: UIApplication, handleActionWithIdentifier identifier: String?,
        forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
            Kahuna.handleNotification(userInfo, withActionIdentifier: identifier,
                withApplicationState: UIApplication.sharedApplication().applicationState)
    }

    public func application(application: UIApplication,
        didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
            NSNotificationCenter.defaultCenter()
                .postNotificationName(Notification.DidRegisterUserNotificationSettings.rawValue, object: nil)
            PushPermissionsManager.sharedInstance.application(application,
                didRegisterUserNotificationSettings: notificationSettings)
    }

    /**
    Updates the updated messages count.
    */
    public func updateUnreadMessagesCount() {
        guard Core.sessionManager.loggedIn else { return }
        Core.oldChatRepository.retrieveUnreadMessageCountWithCompletion { [weak self]
            (result: Result<Int, RepositoryError>) -> Void in
            // Success
            if let count = result.value {
                if let _ = self {
                    // Update the unread message count
                    self?.unreadMessagesCount.value = count
                }
                // Update app's badge
                UIApplication.sharedApplication().applicationIconBadgeNumber = count
                // Notify about it
                NSNotificationCenter.defaultCenter()
                    .postNotificationName(Notification.UnreadMessagesDidChange.rawValue, object: nil)
            }
        }
    }

    
    // MARK: - Private methods
    
    private func tokenStringFromData(data: NSData) -> String {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        return (data.description as NSString).stringByTrimmingCharactersInSet(characterSet)
            .stringByReplacingOccurrencesOfString(" ", withString: "") as String
    }

    private func setupKahuna() {
        Kahuna.launchWithKey(EnvironmentProxy.sharedInstance.kahunaAPIKey)
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
        updateUnreadMessagesCount()

    }

    dynamic private func logout(notification: NSNotification) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        unreadMessagesCount.value = 0
        Kahuna.logout()
    }

    dynamic private func applicationWillEnterForeground(notification: NSNotification) {
        updateUnreadMessagesCount()
    }
}
