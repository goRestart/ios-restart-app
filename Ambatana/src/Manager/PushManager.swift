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
import UrbanAirship_iOS_SDK
import Kahuna

public enum Action {
    case Message(Int, String, String)    // messageType (0: message, 1: offer), productId, buyerId
    case URL(DeepLink)
    
    public init?(userInfo: [NSObject: AnyObject]) {

        if let urlStr = userInfo["url"] as? String, let url = NSURL(string: urlStr), let deepLink = DeepLink(url: url) {
            self = .URL(deepLink)
        }
        else if let type = userInfo["n_t"]?.integerValue, let productId = userInfo["p"] as? String, let buyerId = userInfo["u"] as? String {    // n_t: notification type, p: product id, u: buyer
            self = .Message(type, productId, buyerId)
        }
        else {
            return nil
        }
    }
}

public class PushManager: NSObject, KahunaDelegate {

    // Constants & enum
    enum Notification: String {
        case didReceiveUserInteraction = "didReceiveUserInteraction"
        case unreadMessagesDidChange = "unreadMessagesDidChange"
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
        unreadMessagesCount = UIApplication.sharedApplication().applicationIconBadgeNumber
        
        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "login:", name: MyUserManager.Notification.login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout:", name: MyUserManager.Notification.logout.rawValue, object: nil)
    }
    
    public convenience override init() {
        let installationSaveService = PAInstallationSaveService()
        self.init(installationSaveService: installationSaveService)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Public methods
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> DeepLink? {
        
        // Ask for push permissions
        let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound])
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Setup push notification libraries
        setupUrbanAirship()
        setupKahuna()
        
        // Get the deep link, if any
        var deepLink: DeepLink?
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
            if let action = Action(userInfo: userInfo) {
                switch action {
                case .Message(_, _, _):
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.didReceiveUserInteraction.rawValue, object: userInfo)
                case .URL(let actualDeepLink):
                    deepLink = actualDeepLink
                }
            }
        }
        return deepLink
    }
    
    public func application(application: UIApplication, didFinishLaunchingWithRemoteNotification userInfo: [NSObject: AnyObject]) -> DeepLink? {
        var deepLink: DeepLink?
        if let action = Action(userInfo: userInfo) {
            switch action {
            case .Message(_, _, _):
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.didReceiveUserInteraction.rawValue, object: userInfo)
            case .URL(let dL):
                deepLink = dL
            }
        }
        return deepLink
    }
    
    public func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) -> DeepLink? {
        
        Kahuna.handleNotification(userInfo, withApplicationState: UIApplication.sharedApplication().applicationState);
        
        var deepLink: DeepLink?
        if let action = Action(userInfo: userInfo) {
            switch action {
            case .Message(_, _, _):
                // Update the unread messages count
                updateUnreadMessagesCount()
                
                // Notify about the received user interaction
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.didReceiveUserInteraction.rawValue, object: userInfo)
                
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
                }
                else {
                    PFPush.handlePush(userInfo)
                }
            case .URL(let dL):
                deepLink = dL
                break
            }
        }
        return deepLink
    }
    
    public func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Save the installation with the received device token
        MyUserManager.sharedInstance.saveInstallationDeviceToken(deviceToken)
        
        Kahuna.setDeviceToken(deviceToken);
    }
    
    public func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        Kahuna.handleNotificationRegistrationFailure(error);
    }
    
    public func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        Kahuna.handleNotification(userInfo, withActionIdentifier: identifier, withApplicationState: UIApplication.sharedApplication().applicationState);
    }
    
    /**
        Updates the updated messages count.
    */
    public func updateUnreadMessagesCount() {
       
        ChatManager.sharedInstance.retrieveUnreadMessageCount { [weak self] (result: ChatsUnreadCountRetrieveServiceResult) -> Void in
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
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.unreadMessagesDidChange.rawValue, object: nil)
            }
        }
    }
    
    
    public func updateUrbanAirshipNamedUser(user: User?) {
        UAirship.push()!.namedUser.identifier = user?.objectId
    }
    
    // TODO: Refactor this...
    public func forceKahunaLogin(user: User) {
        let uc = Kahuna.createUserCredentials()
        var loginError: NSError?
        if let userId = user.objectId {
            // TODO: Use Kahuna constants when updating to Xcode 7
//                uc.addCredential(KAHUNA_CREDENTIAL_USER_ID, withValue: userId)
            uc.addCredential("user_id", withValue: userId)
        }
        if let email = user.email {
//                uc.addCredential(KAHUNA_CREDENTIAL_EMAIL, withValue: email)
            uc.addCredential("email", withValue: email)
        }
        Kahuna.loginWithCredentials(uc, error: &loginError)
        if (loginError != nil) {
            print("Login Error : \(loginError!.localizedDescription)", terminator: "")
        }
    }
    
    // MARK: - Private methods
    
    private func setupKahuna() {
//        Kahuna.setDeepIntegrationMode(1)
//        Kahuna.sharedInstance().delegate = self
        
        Kahuna.launchWithKey(EnvironmentProxy.sharedInstance.kahunaAPIKey);

    }
    
    private func setupUrbanAirship() {
        
        let config = UAConfig.defaultConfig()
        config.developmentAppKey = EnvironmentProxy.sharedInstance.urbanAirshipAPIKey
        config.developmentAppSecret = EnvironmentProxy.sharedInstance.urbanAirshipAPISecret
        
        config.productionAppKey = EnvironmentProxy.sharedInstance.urbanAirshipAPIKey
        config.productionAppSecret = EnvironmentProxy.sharedInstance.urbanAirshipAPISecret
        
        config.developmentLogLevel = UALogLevel.None
        // Call takeOff (which creates the UAirship singleton)
        UAirship.takeOff(config)
        
        UAirship.push()!.userNotificationTypes = [.Alert, .Badge, .Sound]
        UAirship.push()!.userPushNotificationsEnabled = true
    }
    
    dynamic private func login(notification: NSNotification) {
        if let user = notification.object as? User {
            updateUrbanAirshipNamedUser(user)
            
            let uc = Kahuna.createUserCredentials()
            var loginError: NSError?
            if let userId = user.objectId {
                // TODO: Use Kahuna constants when updating to Xcode 7
//                uc.addCredential(KAHUNA_CREDENTIAL_USER_ID, withValue: userId)
                uc.addCredential("user_id", withValue: userId)
            }
            if let email = user.email {
//                uc.addCredential(KAHUNA_CREDENTIAL_EMAIL, withValue: email)
                uc.addCredential("email", withValue: email)
            }
            Kahuna.loginWithCredentials(uc, error: &loginError)
            if (loginError != nil) {
                print("Login Error : \(loginError!.localizedDescription)")
            }
        }
        
    }
    
    dynamic private func logout(notification: NSNotification) {
        updateUrbanAirshipNamedUser(notification.object as? User)
        Kahuna.logout()
    }
    
    /**
        Returns the badge value from the given push notification dictionary.
    
        - parameter userInfo: The push notification extra info.
        - returns: The badge value.
    */
    func getBadgeNumberFromNotification(userInfo: [NSObject: AnyObject]) -> Int? {
        if let newBadge = userInfo["badge"] as? Int { return newBadge }
        else if let aps = userInfo["aps"] as? [NSObject: AnyObject] { return self.getBadgeNumberFromNotification(aps) } // compatibility with iOS APS push notification & android.
        else { return nil }
    }
//    
//    /**
//        Returns the notification type from the given push notification dictionary.
//    
//        :param: userInfo The push notification extra info.
//        :returns: The notification type.
//    */
//    func getNotificationType(userInfo: [NSObject: AnyObject]) -> PushNotificationType? {
//        if let oldNotificationType = userInfo["notification_type"]?.integerValue {
//            return PushNotificationType(rawValue: oldNotificationType)
//        }
//        else if let newNotificationType = userInfo["n_t"]?.integerValue {
//            return PushNotificationType(rawValue: newNotificationType)
//        }
//        else if let deepLinkURL = userInfo["url"] as? String {
//            return .DeepLink
//        }
//        else if let aps = userInfo["aps"] as? [NSObject: AnyObject] {   // compatibility with iOS APS push notification & android
//            return self.getNotificationType(aps)
//        }
//        else {
//            return .None
//        }
//    }
}
