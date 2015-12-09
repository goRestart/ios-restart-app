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
    case URL(DeepLink)

    public init?(userInfo: [NSObject: AnyObject]) {

        if let urlStr = userInfo["url"] as? String, let url = NSURL(string: urlStr), let deepLink = DeepLink(url: url) {
            self = .URL(deepLink)
        } else if let type = userInfo["n_t"]?.integerValue, let productId = userInfo["p"] as? String,
            let buyerId = userInfo["u"] as? String {    // n_t: notification type, p: product id, u: buyer
                self = .Message(type, productId, buyerId)
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
    }

    // Singleton
    public static let sharedInstance: PushManager = PushManager()

    // Services
    private var installationSaveService: InstallationSaveService

    // iVars
    public private(set) var unreadMessagesCount: Int

    // MARK: - Lifecycle

    public required init(installationSaveService: InstallationSaveService) {
        self.installationSaveService = installationSaveService
        unreadMessagesCount = 0
        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "login:",
            name: MyUserManager.Notification.login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout:",
            name: MyUserManager.Notification.logout.rawValue, object: nil)
    }

    public convenience override init() {
        let installationSaveService = PAInstallationSaveService()
        self.init(installationSaveService: installationSaveService)
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
                        case .Message(_, _, _):
                            // TODO : fix TabBarVC to load with the corresponding tab depending on the deeplink
                            // Hello, Pull requesters, those comments are here as a tip for for the task of launching
                            // the app propperly when a chat notification is received.
                            //                          guard let chatUrl = NSURL(string: "letgo://chat") else { return nil }
                            //                          deepLink = DeepLink(action: action, url: chatUrl)
                            break
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
                case .Message(_, _, _):
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
            case .Message(_, _, _):
                // Update the unread messages count
                updateUnreadMessagesCount()

                // Notify about the received user interaction (chatVC only observes notification if shown)
                NSNotificationCenter.defaultCenter()
                    .postNotificationName(Notification.DidReceiveUserInteraction.rawValue, object: userInfo)

                // If active, then update the badge
                if application.applicationState == .Active {
                    if let newBadge = self.getBadgeNumberFromNotification(userInfo) {
                        UIApplication.sharedApplication().applicationIconBadgeNumber = newBadge
                        PFInstallation.currentInstallation().badge = newBadge
                        PFInstallation.currentInstallation().saveInBackgroundWithBlock({ (success, error) -> Void in
                            if !success {
                                PFInstallation.currentInstallation().saveEventually(nil)
                            }
                        })
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
            // Save the installation with the received device token
            MyUserManager.sharedInstance.saveInstallationDeviceToken(deviceToken)
            Kahuna.setDeviceToken(deviceToken);
    }

    public func application(application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: NSError) {
            Kahuna.handleNotificationRegistrationFailure(error);
    }

    public func application(application: UIApplication, handleActionWithIdentifier identifier: String?,
        forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
            Kahuna.handleNotification(userInfo, withActionIdentifier: identifier,
                withApplicationState: UIApplication.sharedApplication().applicationState);
    }

    public func application(application: UIApplication,
        didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {

            guard let permissionType = PushPermissionsManager.sharedInstance.permissionType,
                let typePage = PushPermissionsManager.sharedInstance.typePage else { return }

            var trackerEvent: TrackerEvent

            if notificationSettings.types == UIUserNotificationType.None {
                trackerEvent = TrackerEvent.permissionSystemCancel(permissionType, typePage: typePage)
            } else {
                trackerEvent = TrackerEvent.permissionSystemComplete(permissionType, typePage: typePage)
            }
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    /**
    Updates the updated messages count.
    */
    public func updateUnreadMessagesCount() {

        ChatManager.sharedInstance.retrieveUnreadMessageCountWithCompletion { [weak self]
            (result: ChatsUnreadCountRetrieveServiceResult) -> Void in
            // Success
            if let count = result.value {
                if let _ = self {
                    // Update the unread message count
                    self?.unreadMessagesCount = count

                    // Update installation's badge
                    let installation = PFInstallation.currentInstallation()
                    installation.badge = count
                    self?.installationSaveService.save(installation, completion: nil)
                }
                // Update app's badge
                UIApplication.sharedApplication().applicationIconBadgeNumber = count
                // Notify about it
                NSNotificationCenter.defaultCenter()
                    .postNotificationName(Notification.UnreadMessagesDidChange.rawValue, object: nil)
            }
        }
    }

    public func askSystemForPushPermissions() {

        let application = UIApplication.sharedApplication()
        let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert,
            UIUserNotificationType.Badge, UIUserNotificationType.Sound])
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }


    // MARK: - Private methods

    private func setupKahuna() {
        Kahuna.launchWithKey(EnvironmentProxy.sharedInstance.kahunaAPIKey);
    }

    dynamic private func login(notification: NSNotification) {
        if let user = notification.object as? MyUser {

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
