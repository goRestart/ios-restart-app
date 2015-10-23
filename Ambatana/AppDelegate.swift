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
    var userContinuationUrl: NSURL?
    var configManager: ConfigManager!

    // MARK: - UIApplicationDelegate
    
    // MARK: > Lifecycle
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Setup (get the deep link, if any)
        let deepLink = setupLibraries(application, launchOptions: launchOptions)
        setupAppearance()
        
        // iVars
        let configFileName = EnvironmentProxy.sharedInstance.configFileName
        let dao = LGConfigDAO(bundle: NSBundle.mainBundle(), configFileName: configFileName)
        self.configManager = ConfigManager(dao: dao)
        
        // > UI
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if let actualWindow = window {
            
            // Open Splash
            let splashVC = SplashViewController(configManager: configManager)
            let navCtl = UINavigationController(rootViewController: splashVC)
            splashVC.completionBlock = { (succeeded: Bool) -> Void in
            
                // Rebuild user defaults
                UserDefaultsManager.sharedInstance.rebuildUserDefaultsForUser()
                                
                // Show TabBar afterwards
                let tabBarCtl = TabBarController()
                actualWindow.rootViewController = tabBarCtl
                
                // Open the deep link, if any
                if let actualDeepLink = deepLink {
                    tabBarCtl.openDeepLink(actualDeepLink)
                }
                else if self!.userContinuationUrl != nil {
                    self!.consumeUserContinuation(usingTabBar: tabBarCtl)
                }
            }
            actualWindow.rootViewController = navCtl
            actualWindow.makeKeyAndVisible()
        }
        
        //In case of user activity we must return true to handle link in application(continueUserActivity...
        var userContinuation = false
        if let actualLaunchOptions = launchOptions {
            userContinuation = actualLaunchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey] != nil
        }

        // We handle the URL if we're via deep link or Facebook handles it
        return deepLink != nil || FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions) || userContinuation
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        // Tracking
        TrackerProxy.sharedInstance.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
        // Deep linking
        if let deepLink = DeepLink(url: url), let tabBarCtl = self.window?.rootViewController as? TabBarController {
            return tabBarCtl.openDeepLink(deepLink)
        }
        // Facebook
        else {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        // Location
        MyUserManager.sharedInstance.stopSensorLocationUpdates()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        TrackerProxy.sharedInstance.applicationDidEnterBackground(application)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        // Tracking
        TrackerProxy.sharedInstance.applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Force Update Check
        var configManagerUpdate = false
        if let navCtl = window?.rootViewController as? UINavigationController {
            if !(navCtl.topViewController is SplashViewController) {
                configManagerUpdate = true
            }
        }
        else if !(window?.rootViewController is SplashViewController) {
            configManagerUpdate = true
        }
        if configManagerUpdate {
            configManager.updateWithCompletion { () -> Void in
                if let actualWindow = self.window {
                    let itunesURL = String(format: Constants.appStoreURL, arguments: [EnvironmentProxy.sharedInstance.appleAppId])
                    if self.configManager.shouldForceUpdate && UIApplication.sharedApplication().canOpenURL(NSURL(string:itunesURL)!) == true {
                        // show blocking alert
                        let alert = UIAlertController(title: LGLocalizedString.forcedUpdateTitle, message: LGLocalizedString.forcedUpdateMessage, preferredStyle: .Alert)
                        let openAppStore = UIAlertAction(title: LGLocalizedString.forcedUpdateUpdateButton, style: .Default, handler: { (action :UIAlertAction!) -> Void in
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
        MyUserManager.sharedInstance.startSensorLocationUpdates()
    }
    
    func applicationWillTerminate(application: UIApplication) {

    }
    
    // MARK: > App continuation
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            userContinuationUrl = userActivity.webpageURL! // Always exists
            if let tabBarCtl = self.window?.rootViewController as? TabBarController {
                consumeUserContinuation(usingTabBar: tabBarCtl)
            }
            //else we leave it pending until splash screen finishes
            return true
        }
        return false
    }

    // MARK: > Push notification
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        PushManager.sharedInstance.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        PushManager.sharedInstance.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if application.applicationState != .Active {
            if let deepLink = PushManager.sharedInstance.application(application, didReceiveRemoteNotification: userInfo), let tabBarCtl = self.window?.rootViewController as? TabBarController {
                tabBarCtl.openDeepLink(deepLink)
            }
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        PushManager.sharedInstance.application(application, handleActionWithIdentifier: identifier, forRemoteNotification: userInfo, completionHandler: completionHandler)
    }

    
    // MARK: - Private methods
    
    // MARK: > Setup
    
    private func setupLibraries(application: UIApplication, launchOptions: [NSObject: AnyObject]?) -> DeepLink? {

        // LGCoreKit
        LGCoreKit.initialize(launchOptions)
        
        // Crashlytics
#if DEBUG
#else
        Fabric.with([Crashlytics()])
#endif
        
        // Push notifications, get the deep link if any
        var deepLink = PushManager.sharedInstance.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Deep link (in case comes via regular clicked link letgo://...)
        if let actualLaunchOptions = launchOptions, let url = actualLaunchOptions[UIApplicationLaunchOptionsURLKey] as? NSURL {
            deepLink = DeepLink(url: url)
        }
        
        // Tracking
        TrackerProxy.sharedInstance.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // New Relic
        NewRelicAgent.startWithApplicationToken(EnvironmentProxy.sharedInstance.newRelicToken)
        
        // Google app indexing
        GSDAppIndexing.sharedInstance().registerApp(EnvironmentProxy.sharedInstance.googleAppIndexingId)
        
        return deepLink
    }
    
    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = StyleHelper.navBarButtonsColor
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : StyleHelper.navBarTitleFont, NSForegroundColorAttributeName : StyleHelper.navBarTitleColor]
        
        UITabBar.appearance().tintColor = StyleHelper.tabBarIconSelectedColor
    }
    
    // MARK: > Actions
    
    private func openChatListViewController() {
        if let tabBarCtl = self.window?.rootViewController?.presentedViewController as? TabBarController {
            tabBarCtl.switchToTab(.Chats)
        }
    }
    
    private func consumeUserContinuation(usingTabBar tabBarCtl: TabBarController) {
        guard let webpageURL = userContinuationUrl else {
            return
        }
        
        userContinuationUrl = nil
        
        if let deepLink = DeepLink(webUrl: webpageURL) {
            tabBarCtl.openDeepLink(deepLink)
        }
        else {
            UIApplication.sharedApplication().openURL(webpageURL)
        }
    }
}

