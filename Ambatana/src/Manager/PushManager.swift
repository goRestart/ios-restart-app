//
//  PushManager.swift
//  LetGo
//
//  Created by Albert Hernández López on 28/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse
import UrbanAirship_iOS_SDK
import Kahuna


@objc public enum PushNotificationType: Int {
    case Offer = 0, Message = 1, Marketing = 2
}

public class PushManager: NSObject, KahunaDelegate {

    // Constants & enum
    enum Notification: String {
        case didReceiveUserInteraction = "didReceiveUserInteraction"
        case didReceiveMarketingMessage = "didReceiveMarketingMessage"
        
        case unreadMessagesDidChange = "unreadMessagesDidChange"
    }
    
    // Singleton
    public static let sharedInstance: PushManager = PushManager()
    
    // iVars
    public var unreadMessagesCount: Int
    
    // MARK: - Lifecycle
    
    public override init() {
        unreadMessagesCount = UIApplication.sharedApplication().applicationIconBadgeNumber
        
        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "login:", name: MyUserManager.Notification.login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout:", name: MyUserManager.Notification.logout.rawValue, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Public methods
    
    public func prepareApplicationForRemoteNotifications(application: UIApplication) {
        let userNotificationTypes = (UIUserNotificationType.Alert |
                                     UIUserNotificationType.Badge |
                                     UIUserNotificationType.Sound)
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        setupUrbanAirship()
        
        setupKahuna()

    }
    
    public func application(application: UIApplication, didFinishLaunchingWithRemoteNotification userInfo: [NSObject: AnyObject]) {
        if let type = getNotificationType(userInfo) {
            notifyDidReceiveRemoteNotificationType(type, userInfo: userInfo)
            
            if type == .Offer || type == .Message {
                updateUnreadMessagesCount()
            }
        }
    }
    
    public func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], notActiveCompletion: (PushNotificationType) -> Void) {
        
        Kahuna.handleNotification(userInfo, withApplicationState: UIApplication.sharedApplication().applicationState);
        
        if let type = getNotificationType(userInfo) {
            notifyDidReceiveRemoteNotificationType(type, userInfo: userInfo)

            if type == .Offer || type == .Message {
                updateUnreadMessagesCount()
            }
            
            if application.applicationState != .Active {
                notActiveCompletion(type)
            }
        }
        
        if application.applicationState == .Active {
            // Update the badge
            if let newBadge = self.getBadgeNumberFromNotification(userInfo) {
                UIApplication.sharedApplication().applicationIconBadgeNumber = newBadge
                PFInstallation.currentInstallation().badge = newBadge
                PFInstallation.currentInstallation().saveInBackgroundWithBlock({ (success, error) -> Void in
                    if !success { PFInstallation.currentInstallation().saveEventually(nil) }
                })
            }
        }
        else {
            PFPush.handlePush(userInfo)
        }
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
       
        if let myUser = MyUserManager.sharedInstance.myUser() {
            let conversationsFrom = PFQuery(className: "Conversations")
            conversationsFrom.whereKey("user_from", equalTo: myUser) // I am the user that started the conversation
            let conversationsTo = PFQuery(className: "Conversations")
            conversationsTo.whereKey("user_to", equalTo: myUser)     // I am the user that received the conversation.
            
            let query = PFQuery.orQueryWithSubqueries([conversationsFrom, conversationsTo])
            query.includeKey("product")
            query.includeKey("user_to")
            query.includeKey("user_from")
            query.orderByDescending("updatedAt")
            
            // Run the query
            query.findObjectsInBackgroundWithBlock({ [weak self] (results, error) -> Void in
                if error == nil {
                    if let conversations = results as? [PFObject] {
                        // Update the unread messages count
                        let unreadMessageCount = PushManager.getUnreadMessageCountFromConversations(conversations)
                        self?.unreadMessagesCount = unreadMessageCount
                        
                        // Update app's badge
                        UIApplication.sharedApplication().applicationIconBadgeNumber = unreadMessageCount
                        
                        // Update installation's badge
                        PFInstallation.currentInstallation().badge = unreadMessageCount
                        PFInstallation.currentInstallation().saveInBackground()
                        
                        // Notify about it
                        NSNotificationCenter.defaultCenter().postNotificationName(Notification.unreadMessagesDidChange.rawValue, object: nil)
                    }
                }
            })
        }
    }
    
    
    public func updateUrbanAirshipNamedUser(user: User?) {
        UAirship.push()!.namedUser.identifier = user?.objectId
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
        
        UAirship.push()!.userNotificationTypes = (.Alert | .Badge | .Sound)
        UAirship.push()!.userPushNotificationsEnabled = true
    }
    
    dynamic private func login(notification: NSNotification) {
        if let user = notification.object as? User {
            updateUrbanAirshipNamedUser(user)
            
            let uc = Kahuna.createUserCredentials()
            var loginError: NSError?
            if let userId = user.objectId {
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
    
    
    // MARK: > NSNotificationCenter
    
    /**
        Notifies the notification listeners that a remote notification arrived.
        
        :param: type The notification type.
        :param: userInfo The push notification extra info.
    */
    private func notifyDidReceiveRemoteNotificationType(type: PushNotificationType, userInfo: [NSObject: AnyObject]) {
        if type == .Offer || type == .Message {
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.didReceiveUserInteraction.rawValue, object: userInfo)
        }
        else if type == .Marketing {
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.didReceiveMarketingMessage.rawValue, object: userInfo)
        }
    }
    
    /**
        Returns the badge value from the given push notification dictionary.
    
        :param: userInfo The push notification extra info.
        :returns: The badge value.
    */
    func getBadgeNumberFromNotification(userInfo: [NSObject: AnyObject]) -> Int? {
        if let newBadge = userInfo["badge"] as? Int { return newBadge }
        else if let aps = userInfo["aps"] as? [NSObject: AnyObject] { return self.getBadgeNumberFromNotification(aps) } // compatibility with iOS APS push notification & android.
        else { return nil }
    }
    
    /**
        Returns the notification type from the given push notification dictionary.
    
        :param: userInfo The push notification extra info.
        :returns: The notification type.
    */
    func getNotificationType(userInfo: [NSObject: AnyObject]) -> PushNotificationType? {
        if let oldNotificationType = userInfo["notification_type"]?.integerValue { return PushNotificationType(rawValue: oldNotificationType) }
        else if let newNotificationType = userInfo["n_t"]?.integerValue { return PushNotificationType(rawValue: newNotificationType) }
        else if let aps = userInfo["aps"] as? [NSObject: AnyObject] { return self.getNotificationType(aps) } // compatibility with iOS APS push notification & android.
        else { return nil }
    }
    
//    func getNotificationAlertMessage(userInfo: [NSObject: AnyObject]) -> String? {
//        if let msg = userInfo["alert"] as? String { return msg }
//        else if let aps = userInfo["aps"] as? [String: AnyObject] { // compatibility with iOS APS push notification & android
//            return aps["alert"] as? String
//        } else { return nil }
//    }
    
    // MARK: > Helper
    
    /**
        Retrieves the total unread message count from the given conversations.
    
        :param: conversations The conversations.
        :returns: The total unread message count.
    */
    private static func getUnreadMessageCountFromConversations(conversations: [PFObject]) -> Int {
        var unreadMessagesCount = 0
        
        if let myUser = MyUserManager.sharedInstance.myUser() {
            for conversation in conversations {
                if let userFrom = conversation["user_from"] as? User,
                   let userTo = conversation["user_to"] as? User {
                    if userFrom.objectId == myUser.objectId {
                        unreadMessagesCount += conversation["nr_msg_to_read_from"]?.integerValue ?? 0
                    }
                    else if userTo.objectId == myUser.objectId {
                        unreadMessagesCount += conversation["nr_msg_to_read_to"]?.integerValue ?? 0
                    }
                }
            }
        }
        return unreadMessagesCount
    }
    
    // - KAHUNA Delegate Method:
    
    public func kahunaPushMessageReceived(message: String!, withDictionary extras: [NSObject : AnyObject]!, withApplicationState applicationState: UIApplicationState) {

        NSLog("Received Push from Kahuna!");
        
        // Check on the applicationState before deep-linking into the app
        // Push received when app is in Foreground should not take users to specific view via DeepLinking.
        // Non view navigation code can still be performed when Push is received with app in foreground.
        
        if (extras["url"] != nil) {
            if (applicationState != UIApplicationState.Active) {
                // Deep link into the app.
            } else {
                // Push came when the app is in Foreground. You can show an UIAlertView dialog with the message.
                // When the user clicks on the "OK" button, Deep link into the app.
            }
        }
        
        // For iOS8 actionable push notifications we will send the selected action in this callback.
        // Actionable push notifications does not need the applicationState check as the user cannot
        // take an action when the app in foreground.
        
        if (extras["k_action_identifier"] != nil) {
            var pushAction : AnyObject = extras["k_action_identifier"]!;
            // Act on the pushAction to perform actions for the user.
        }
    }
}
