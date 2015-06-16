//
//  PushManager.swift
//  LetGo
//
//  Created by Albert Hernández López on 28/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse

@objc public enum PushNotificationType: Int {
    case Offer = 0, Message = 1, Marketing = 2
}

public class PushManager {

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
    
    public init() {
        unreadMessagesCount = UIApplication.sharedApplication().applicationIconBadgeNumber
    }
    
    // MARK: - Public methods
    
    public func application(application: UIApplication, didFinishLaunchingWithRemoteNotification userInfo: [NSObject: AnyObject]) {
        if let type = getNotificationType(userInfo) {
            notifyDidReceiveRemoteNotificationType(type, userInfo: userInfo)
            
            if type == .Offer || type == .Message {
                updateUnreadMessagesCount()
            }
        }
    }
    
    public func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], notActiveCompletion: (PushNotificationType) -> Void) {
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
        
//        // Update the installation
//        let installation = PFInstallation.currentInstallation()
//        installation.setDeviceTokenFromData(deviceToken)
//        installation.channels = [""]
//        
//        // FIXME: This shouldn't be in here
//        if PFUser.currentUser() != nil {
//            installation["user_objectId"] = PFUser.currentUser()!.objectId
//            installation["username"] = PFUser.currentUser()!["username"]
//        }
//        installation.saveInBackground()
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
    
    // MARK: - Private methods
    
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
                let userFrom = conversation["user_from"] as? PFObject
                let userTo = conversation["user_to"] as? PFObject
                
                if userFrom?.objectId == myUser.objectId {
                    unreadMessagesCount += conversation["nr_msg_to_read_from"]?.integerValue ?? 0
                }
                else if userTo?.objectId == myUser.objectId {
                    unreadMessagesCount += conversation["nr_msg_to_read_to"]?.integerValue ?? 0
                }
            }
        }
        return unreadMessagesCount
    }
}
