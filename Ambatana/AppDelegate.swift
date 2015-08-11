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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // iVars
    var window: UIWindow?

    // MARK: - UIApplicationDelegate
    
    // MARK: > Lifecycle
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        setupLibraries(application, launchOptions: launchOptions)
        setupAppearance()

        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
            PushManager.sharedInstance.application(application, didFinishLaunchingWithRemoteNotification: remoteNotification)
        }
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if let actualWindow = window {
            let splashVC = SplashViewController()
            let navCtl = UINavigationController(rootViewController: splashVC)
            splashVC.completionBlock = { [weak self] (succeeded: Bool) -> Void in
                actualWindow.rootViewController = TabBarController()
            }
            actualWindow.rootViewController = navCtl
            actualWindow.makeKeyAndVisible()
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        // Tracking
        TrackerProxy.sharedInstance.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
        // Facebook
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        // Location
        LocationManager.sharedInstance.stopLocationUpdates()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        // Tracking
        TrackerProxy.sharedInstance.applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Force Update Check

        if !(window?.rootViewController is SplashViewController) {
            UpdateFileCfgManager.sharedInstance.getUpdateCfgFileFromServer { (forceUpdate: Bool) -> Void in
                if let actualWindow = self.window {
                    let itunesURL = String(format: Constants.appStoreURL, arguments: [EnvironmentProxy.sharedInstance.appleAppId])
                    if forceUpdate && UIApplication.sharedApplication().canOpenURL(NSURL(string:itunesURL)!) == true {
                        // show blocking alert
                        let alert = UIAlertController(title: NSLocalizedString("forced_update_title", comment: ""), message: NSLocalizedString("forced_update_message", comment: ""), preferredStyle: .Alert)
                        let openAppStore = UIAlertAction(title: NSLocalizedString("forced_update_update_button", comment: ""), style: .Default, handler: { (action :UIAlertAction!) -> Void in
                            UIApplication.sharedApplication().openURL(NSURL(string:itunesURL)!)
                        })
                        
                        alert.addAction(openAppStore)
                        actualWindow.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        // Tracking
        TrackerProxy.sharedInstance.applicationDidBecomeActive(application)
        
        // Location
        LocationManager.sharedInstance.startLocationUpdates()
        
    }
    
    func applicationWillTerminate(application: UIApplication) {

    }

    // MARK: > Push notification
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        PushManager.sharedInstance.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PushManager.sharedInstance.application(application, didReceiveRemoteNotification: userInfo, notActiveCompletion: { [weak self] (type) -> Void in
            if type == .Offer || type == .Message {
                self?.openChatListViewController()
            }
//            else if type == .Marketing {
//                self?.showMarketingAlertWithNotificationMessage()
//            }
        })
    }
    
    // MARK: - Private methods
    
    // MARK: > Setup
    
    private func setupLibraries(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {

        // LGCoreKit
        LGCoreKit.initialize(launchOptions)
        
        // Crashlytics
#if DEBUG
#else
            Fabric.with([Crashlytics()])
#endif
        
        // Push notifications
        PushManager.sharedInstance.prepareApplicationForRemoteNotifications(application)
        PushManager.sharedInstance.setupUrbanAirship()
        
        // Tracking
        TrackerProxy.sharedInstance.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = StyleHelper.navBarButtonsColor
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : StyleHelper.navBarTitleFont, NSForegroundColorAttributeName : StyleHelper.navBarTitleColor]
        
        UITabBar.appearance().tintColor = StyleHelper.tabBarIconSelectedColor
        
        UIPageControl.appearance().pageIndicatorTintColor = StyleHelper.pageIndicatorSelectedColor
        UIPageControl.appearance().currentPageIndicatorTintColor = StyleHelper.pageIndicatorUnselectedColor
    }
    
    // MARK: > Actions
    
    private func openChatListViewController() {
        if let tabBarCtl = self.window?.rootViewController?.presentedViewController as? TabBarController {
            tabBarCtl.switchToTab(.Chats)
        }
    }

    // FIXME: Legacy...
    
//    private func showMarketingAlertWithNotificationMessage(message: String) {
//        if let tabBarCtl = self.window?.rootViewController?.presentedViewController as? TabBarController {
//            tabBarCtl.displayMessage(message)
//        }
//    }
    
    // MARK: > Push notification
    
//    func getNotificationAlertMessage(userInfo: [NSObject: AnyObject]) -> String? {
//        if let msg = userInfo["alert"] as? String { return msg }
//        else if let aps = userInfo["aps"] as? [String: AnyObject] { // compatibility with iOS APS push notification & android
//            return aps["alert"] as? String
//        } else { return nil }
//    }
}

