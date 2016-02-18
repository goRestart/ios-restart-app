//
//  PushManager.swift
//  LetGo
//
//  Created by Albert Hernández López on 28/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse
import Result
import Kahuna

public enum Action {
    case Message(Int, String, String)    // messageType (0: message, 1: offer), productId, buyerId
    case Conversation(Int, String) // messageType (0: message, 1: offer), conversationId
    case URL(DeepLink)

    public init?(userInfo: [NSObject: AnyObject]) {

        if let urlStr = userInfo["url"] as? String, let url = NSURL(string: urlStr), let deepLink = DeepLink(url: url) {
            self = .URL(deepLink)
        } else if let type = userInfo["n_t"]?.integerValue, let productId = userInfo["p"] as? String,
            let buyerId = userInfo["u"] as? String {    // n_t: notification type, p: product id, u: buyer
                self = .Message(type, productId, buyerId)
        } else if let conversationId = userInfo["c"] as? String {
            self = .Conversation(userInfo["n_t"]?.integerValue ?? 0, conversationId)
        } else {
            return nil
        }
    }
}

public class PushManager: NSObject, KahunaDelegate {

    // Constants & enum
    enum Notification: String {
        case DidReceiveUserInteraction
        case UnreadMessagesDidChange
        case DidRegisterUserNotificationSettings
    }

    // Singleton
    public static let sharedInstance: PushManager = PushManager()

    // Services
    private var installationRepository: InstallationRepository
    
    // iVars
    public private(set) var unreadMessagesCount: Int

    // MARK: - Lifecycle

    public required init(installationRepository: InstallationRepository) {
        self.installationRepository = installationRepository
        unreadMessagesCount = 0
        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "login:",
            name: SessionManager.Notification.Login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout:",
            name: SessionManager.Notification.Logout.rawValue, object: nil)
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
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> DeepLink? {

            // Setup push notification libraries
            setupKahuna()

            // Get the deep link, if any
            var deepLink: DeepLink?
            if let userInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
                as? [NSObject : AnyObject] {
                    if let action = Action(userInfo: userInfo) {
                        switch action {
                        case .Message, .Conversation:
                            guard let chatUrl = NSURL(string: "letgo://chat") else { return nil }
                            deepLink = DeepLink(action: action, url: chatUrl)
                        case .URL(let actualDeepLink):
                            deepLink = actualDeepLink
                        }
                    }
            }
            return deepLink
    }

    public func application(application: UIApplication,
        didFinishLaunchingWithRemoteNotification userInfo: [NSObject: AnyObject]) -> DeepLink? {
            var deepLink: DeepLink?
            if let action = Action(userInfo: userInfo) {
                switch action {
                case .Message, .Conversation:
                    NSNotificationCenter.defaultCenter()
                        .postNotificationName(Notification.DidReceiveUserInteraction.rawValue, object: userInfo)
                case .URL(let dL):
                    deepLink = dL
                }
            }
            return deepLink
    }

    public func application(application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) -> DeepLink? {

            Kahuna.handleNotification(userInfo, withApplicationState: UIApplication.sharedApplication().applicationState)

            var deepLink: DeepLink?

            guard let action = Action(userInfo: userInfo) else { return deepLink }

            switch action {
            case .Message, .Conversation:
                // Update the unread messages count
                updateUnreadMessagesCount()

                // Notify about the received user interaction (chatVC only observes notification if shown)
                NSNotificationCenter.defaultCenter()
                    .postNotificationName(Notification.DidReceiveUserInteraction.rawValue, object: userInfo)

                // If active, then update the badge
                if application.applicationState == .Active {
                    if let newBadge = self.getBadgeNumberFromNotification(userInfo) {
                        UIApplication.sharedApplication().applicationIconBadgeNumber = newBadge
                    }
                } else {
                    guard let chatUrl = NSURL(string: "letgo://chat") else { return nil }
                    deepLink = DeepLink(action: action, url: chatUrl)
                    PFPush.handlePush(userInfo)
                }
            case .URL(let dL):
                guard application.applicationState != .Active else { return nil }
                deepLink = dL
                break
            }
            return deepLink
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
        Core.chatRepository.retrieveUnreadMessageCountWithCompletion { [weak self]
            (result: Result<Int, RepositoryError>) -> Void in
            // Success
            if let count = result.value {
                if let _ = self {
                    // Update the unread message count
                    self?.unreadMessagesCount = count
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
        Kahuna.logout()
    }

    /**
    Returns the badge value from the given push notification dictionary.

    - parameter userInfo: The push notification extra info.
    - returns: The badge value.
    */
    func getBadgeNumberFromNotification(userInfo: [NSObject: AnyObject]) -> Int? {
        if let newBadge = userInfo["badge"] as? Int {
            return newBadge
        } else if let aps = userInfo["aps"] as? [NSObject: AnyObject] {
            return self.getBadgeNumberFromNotification(aps)
        } else {
            return nil
        }
    }
}
