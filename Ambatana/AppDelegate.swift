//
//  AppDelegate.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Crashlytics
import Fabric
import FBSDKCoreKit
import LGCoreKit
import Parse
import UIKit

private let kLetGoVersionNumberKey = "com.letgo.LetGoVersionNumberKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // initializate parse
        //Parse.enableLocalDatastore()
        Parse.setApplicationId(EnvironmentProxy.sharedInstance.parseApplicationId,
                               clientKey: EnvironmentProxy.sharedInstance.parseClientId)
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions ?? [:])
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
               
        // Crashlytics
#if DEBUG
#else
        Fabric.with([Crashlytics()])
#endif
        // LGCoreKit
        LGCoreKit.initialize()
        // > Retrieve a session token
        SessionManager.sharedInstance.retrieveSessionToken()
        
        // Registering for push notifications && Installation
        if iOSVersionAtLeast("8.0") { // we are on iOS 8.X+ use the new way.
            let userNotificationTypes = (UIUserNotificationType.Alert |
                UIUserNotificationType.Badge |
                UIUserNotificationType.Sound)
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else { // we're on ios < 8, use the old way
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert|UIRemoteNotificationType.Badge|UIRemoteNotificationType.Sound)
        }
        
        // responding to push notifications received while app not launched.
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            //println("Opened app because of push notification: \(remoteNotification)")
            if let notificationType = self.getNotificationType(remoteNotification as [NSObject : AnyObject]) {
                if notificationType == .Offer || notificationType == .Message {
                    NSNotificationCenter.defaultCenter().postNotificationName(kLetGoUserBadgeChangedNotification, object: remoteNotification)
                    self.openChatListViewController()
                } else {
                    // Do nothing. As per specifications, we should not show an alert of anything if the user opens the app responding to a push notification.
                }
            }
        }
        
        // initialize location services
        LocationManager.sharedInstance.startLocationUpdates()
        
        // Tracking
        TrackingHelper.appDidFinishLaunching()
        
        // > check version and track if new install
        var newInstall = false
        if let letgoVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"]?.floatValue {
            if let storedVersion = NSUserDefaults.standardUserDefaults().objectForKey(kLetGoVersionNumberKey)?.floatValue {
                // check if stored version is the same as our version.
                if letgoVersion != storedVersion {
                    newInstall = true
                    NSUserDefaults.standardUserDefaults().setObject("\(letgoVersion)", forKey: kLetGoVersionNumberKey)
                }
            } else { // no stored version. This is a new install. Store our version now.
                newInstall = true
                NSUserDefaults.standardUserDefaults().setObject("\(letgoVersion)", forKey: kLetGoVersionNumberKey)
            }
        }
        if newInstall {
            TrackingHelper.trackEvent(.Install, parameters: nil)
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func openChatListViewController() {
        if let rootViewController = self.window?.rootViewController?.presentedViewController as? RootViewController { // make sure we are logged in and everything's in its place
            if let navigationController = rootViewController.contentViewController as? DLHamburguerNavigationController {
                // don't open the chat view controller if it's the current chat view controller already.
                if navigationController.viewControllers?.last is ChatListViewController { return }
                // we are logged in. Check that we have a valid LetGo navigation controller
                let clvc = ChatListViewController()
                navigationController.pushViewController(clvc, animated: true)
            }
        }
    }
    
    func showMarketingAlertWithNotificationMessage(message: String) {
        if let rootViewController = self.window?.rootViewController?.presentedViewController as? RootViewController { // make sure we are logged in and everything's in its place
            if let navigationController = rootViewController.contentViewController as? DLHamburguerNavigationController {
                navigationController.showAutoFadingOutMessageAlert(message)
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // Location
        LocationManager.sharedInstance.stopLocationUpdates()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

        // Update the session token
        SessionManager.sharedInstance.retrieveSessionToken()
        
        // Location
        LocationManager.sharedInstance.startLocationUpdates()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Tracking
        TrackingHelper.appDidBecomeActive()
    }

    // receive push notifications.
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = [""]
        if PFUser.currentUser() != nil {
            installation["user_objectId"] = PFUser.currentUser()!.objectId
            installation["username"] = PFUser.currentUser()!["username"]
        }
        installation.saveInBackgroundWithBlock { (success, error) -> Void in
            //println("Installation saved. Success: \(success), error: \(error)")
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        // if the App is already running, don't show an alert or open the chatListViewController.
        if application.applicationState == .Active {
            // update the badge
            if let newBadge = self.getBadgeNumberFromNotification(userInfo) {
                UIApplication.sharedApplication().applicationIconBadgeNumber = newBadge
                PFInstallation.currentInstallation().badge = newBadge
                PFInstallation.currentInstallation().saveInBackgroundWithBlock({ (success, error) -> Void in
                    if !success { PFInstallation.currentInstallation().saveEventually(nil) }
                })
            }
            // show an alert only if this is a marketing message.
            if let notificationType = self.getNotificationType(userInfo), let notificationMsg = self.getNotificationAlertMessage(userInfo) {
                if notificationType == .Offer || notificationType == .Message { // message/offer
                    NSNotificationCenter.defaultCenter().postNotificationName(kLetGoUserBadgeChangedNotification, object: userInfo)
                } else if notificationType == .Marketing { // marketing.
                    self.showMarketingAlertWithNotificationMessage(notificationMsg)
                }
            }
        } else {
            // Fully respond to the notification.
            PFPush.handlePush(userInfo)
            if let notificationType = self.getNotificationType(userInfo), let notificationMsg = self.getNotificationAlertMessage(userInfo) {
                //println("Notification type: \(notificationType.rawValue)")
                if notificationType == .Offer || notificationType == .Message { // message/offer
                    NSNotificationCenter.defaultCenter().postNotificationName(kLetGoUserBadgeChangedNotification, object: userInfo)
                    // push a chat list to see the messages.
                    self.openChatListViewController()
                } else { // marketing
                    self.showMarketingAlertWithNotificationMessage(notificationMsg)
                }
            }
        }
        // notify any observers
        //println("Received push notification: \(userInfo)")
        
    }
    
    func getBadgeNumberFromNotification(userInfo: [NSObject: AnyObject]) -> Int? {
        if let newBadge = userInfo["badge"] as? Int { return newBadge }
        else if let aps = userInfo["aps"] as? [NSObject: AnyObject] { return self.getBadgeNumberFromNotification(aps) } // compatibility with iOS APS push notification & android.
        else { return nil }
    }
    
    func getNotificationType(userInfo: [NSObject: AnyObject]) -> LetGoChatNotificationType? {
        if let oldNotificationType = userInfo["notification_type"]?.integerValue { return LetGoChatNotificationType(rawValue: oldNotificationType) }
        else if let newNotificationType = userInfo["n_t"]?.integerValue { return LetGoChatNotificationType(rawValue: newNotificationType) }
        else if let aps = userInfo["aps"] as? [NSObject: AnyObject] { return self.getNotificationType(aps) } // compatibility with iOS APS push notification & android.
        else { return nil }
    }
    
    func getNotificationAlertMessage(userInfo: [NSObject: AnyObject]) -> String? {
        if let msg = userInfo["alert"] as? String { return msg }
        else if let aps = userInfo["aps"] as? [String: AnyObject] { // compatibility with iOS APS push notification & android
            return aps["alert"] as? String
        } else { return nil }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // stop location services (if any).
//        LocationManager.sharedInstance.terminate()
    }


}

