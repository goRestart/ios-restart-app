//
//  AppDelegate.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kLetGoParseApplicationID = "3zW8RQIC7yEoG9WhWjNduehap6csBrHQ2whOebiz"
private let kLetGoParseClientKey = "4dmYjzpoyMbAdDdmCTBG6s7TTHtNTAaQaJN6YOAk"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // initializate parse
        //Parse.enableLocalDatastore()
        Parse.setApplicationId(kLetGoParseApplicationID, clientKey: kLetGoParseClientKey)
        PFFacebookUtils.initializeFacebook()
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
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
        
        // responding to push notifications received while in background.
        println("Launch options: \(launchOptions)")
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            NSNotificationCenter.defaultCenter().postNotificationName(kLetGoUserBadgeChangedNotification, object: remoteNotification)
            self.openChatListViewController()
        }
        
        // initialize location services
        LocationManager.sharedInstance
        
        return true
    }
    
    func openChatListViewController() {
        if let rootViewController = self.window?.rootViewController?.presentedViewController as? RootViewController { // make sure we are logged in and everything's in its place
            if let navigationController = rootViewController.contentViewController as? DLHamburguerNavigationController {
                // don't open the chat view controller if it's the current chat view controller already.
                if navigationController.viewControllers?.last is ChatListViewController { return }
                // we are logged in. Check that we have a valid LetGo navigation controller
                if let chatListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("conversationsViewController") as? ChatListViewController { // ... and that we can instantiate the chat controller.
                    navigationController.pushViewController(chatListVC, animated: true)
                }
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication, withSession: PFFacebookUtils.session())
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }

    // receive push notifications.
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation["deviceTokenLastModified"] = NSDate().timeIntervalSince1970
        installation.channels = [""]
        if PFUser.currentUser() != nil {
            installation["user_objectId"] = PFUser.currentUser()!.objectId
            installation["username"] = PFUser.currentUser()!["username"]
        }
        installation.saveInBackgroundWithBlock { (success, error) -> Void in
            println("Installation saved. Success: \(success), error: \(error)")
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
        } else {
            // Fully respond to the notification.
            PFPush.handlePush(userInfo)
            // push a chat list to see the messages.
            self.openChatListViewController() // Not really nice when we are using the App?
        }
        // notify any observers
        println("Received push notification: \(userInfo)")
        NSNotificationCenter.defaultCenter().postNotificationName(kLetGoUserBadgeChangedNotification, object: userInfo)
        
    }
    
    func getBadgeNumberFromNotification(userInfo: [NSObject: AnyObject]) -> Int? {
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            if let newBadge = aps["badge"] as? Int {
                return newBadge
            }
        }
        return nil
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Close facebook session
        PFFacebookUtils.session()!.close()
        
        // stop location services (if any).
        LocationManager.sharedInstance.terminate()
    }


}

