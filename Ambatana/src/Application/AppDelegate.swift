//
//  AppDelegate.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Crashlytics
import CocoaLumberjack
import Fabric
import FBSDKCoreKit
import LGCoreKit
import UIKit
import FBSDKCoreKit
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // iVars
    var window: UIWindow?
    var userContinuationUrl: NSURL?
    var configManager: ConfigManager!
    var shouldStartLocationServices: Bool = true

    enum ShortcutItemType: String {
        case Sell = "letgo.sell"
        case StartBrowsing = "letgo.startBrowsing"
    }

    func locationManagerDidChangeAuthorization() {
        var trackerEvent: TrackerEvent
        TrackerProxy.sharedInstance.gpsPermissionChanged()
        if Core.locationManager.didAcceptPermissions {
            trackerEvent = TrackerEvent.permissionSystemComplete(.Location, typePage: .ProductList)
        } else {
            trackerEvent = TrackerEvent.permissionSystemCancel(.Location, typePage: .ProductList)
        }
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    
    // MARK: - UIApplicationDelegate
    
    // MARK: > Lifecycle
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Setup
        setupLibraries(application, launchOptions: launchOptions)
        setupAppearance()
        
        // iVars
        let configFileName = EnvironmentProxy.sharedInstance.configFileName
        let dao = LGConfigDAO(bundle: NSBundle.mainBundle(), configFileName: configFileName)
        self.configManager = ConfigManager(dao: dao)
        
        // > UI
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        guard let window = window else { return false }
        
        LGCoreKit.start()
        
        let tabBarCtl = TabBarController()
        window.rootViewController = tabBarCtl
        window.makeKeyAndVisible()

        let deepLinksRouterContinuation = DeepLinksRouter.sharedInstance.initWithLaunchOptions(launchOptions)
        let fbSdkContinuation = FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        let afterOnboardingClosure = { [weak self] in
            self?.shouldStartLocationServices = true
            tabBarCtl.consumeDeepLinkIfAvailable()
        }

        if self.shouldOpenOnboarding() {
            PushPermissionsManager.sharedInstance.shouldAskForListPermissionsOnCurrentSession = false
            let vc = TourLoginViewController(viewModel: TourLoginViewModel(), completion: afterOnboardingClosure)
            tabBarCtl.presentViewController(vc, animated: false, completion: nil)
            UserDefaultsManager.sharedInstance.saveDidShowOnboarding()
            self.shouldStartLocationServices = false
        } else {
            afterOnboardingClosure()
        }

        return deepLinksRouterContinuation || fbSdkContinuation
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return app(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    @available(iOS 9.0, *)
    func application(application: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let sourceApplication: String? = options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String
        let annotation: AnyObject? = options[UIApplicationOpenURLOptionsAnnotationKey]
        return app(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        DeepLinksRouter.sharedInstance.performActionForShortcutItem(shortcutItem, completionHandler: completionHandler)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        Core.locationManager.stopSensorLocationUpdates()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        TrackerProxy.sharedInstance.applicationDidEnterBackground(application)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

        LGCoreKit.refreshData()
        
        // Tracking
        TrackerProxy.sharedInstance.applicationWillEnterForeground(application)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Force Update Check
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
        
        if shouldStartLocationServices {
            Core.locationManager.startSensorLocationUpdates()
        }
        
        // Tracking
        TrackerProxy.sharedInstance.applicationDidBecomeActive(application)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        
    }
    
    
    // MARK: > App continuation
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        let ownUserActivity = DeepLinksRouter.sharedInstance.continueUserActivity(userActivity,
            restorationHandler: restorationHandler)
        let branchUserActivity = Branch.getInstance().continueUserActivity(userActivity)
        return ownUserActivity || branchUserActivity
    }

    
    // MARK: > Push notification
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        PushManager.sharedInstance.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        PushManager.sharedInstance.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PushManager.sharedInstance.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        PushManager.sharedInstance.application(application, handleActionWithIdentifier: identifier, forRemoteNotification: userInfo, completionHandler: completionHandler)
        DeepLinksRouter.sharedInstance.handleActionWithIdentifier(identifier, forRemoteNotification: userInfo,
            completionHandler: completionHandler)
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        PushManager.sharedInstance.application(application, didRegisterUserNotificationSettings: notificationSettings)
    }
    
    
    // MARK: - Private methods
    
    // MARK: > Setup
    
    private func setupLibraries(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
        let environmentHelper = EnvironmentsHelper()
        EnvironmentProxy.sharedInstance.setEnvironmentType(environmentHelper.appEnvironment)

        // Debug
        Debug.loggingOptions = [AppLoggingOptions.Navigation]
        LGCoreKit.loggingOptions = [CoreLoggingOptions.Networking, CoreLoggingOptions.Persistence,
            CoreLoggingOptions.Token, CoreLoggingOptions.Session]

        // Logging
        #if GOD_MODE
            DDLog.addLogger(DDTTYLogger.sharedInstance())       // TTY = Xcode console
            DDTTYLogger.sharedInstance().colorsEnabled =  true
            DDLog.addLogger(DDASLLogger.sharedInstance())       // ASL = Apple System Logs
        #endif
        DDLog.addLogger(CrashlyticsLogger.sharedInstance)

        // Fabric
        #if DEBUG
        #else
            Fabric.with([Crashlytics.self])
        #endif

        // LGCoreKit
        LGCoreKit.initialize(launchOptions, environmentType: environmentHelper.coreEnvironment)
        Core.reporter.addReporter(CrashlyticsReporter())

        // Observe location auth status changes
        let name = LocationManager.Notification.LocationDidChangeAuthorization.rawValue
        let selector: Selector = "locationManagerDidChangeAuthorization"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: name, object: nil)

        // Branch.io
        if let branch = Branch.getInstance() {
            branch.initSessionWithLaunchOptions(launchOptions, andRegisterDeepLinkHandlerUsingBranchUniversalObject: {
                object, properties, error in
                DeepLinksRouter.sharedInstance.deepLinkFromBranchObject(object, properties: properties)
            })
        }

        // Facebook id
        FBSDKSettings.setAppID(EnvironmentProxy.sharedInstance.facebookAppId)

        // Push notifications, get the deep link if any
        PushManager.sharedInstance.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Tracking
        TrackerProxy.sharedInstance.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // New Relic
        NewRelicAgent.startWithApplicationToken(EnvironmentProxy.sharedInstance.newRelicToken)
        
        // Google app indexing
        GSDAppIndexing.sharedInstance().registerApp(EnvironmentProxy.sharedInstance.googleAppIndexingId)
    }
    
    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = StyleHelper.navBarButtonsColor
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : StyleHelper.navBarTitleFont, NSForegroundColorAttributeName : StyleHelper.navBarTitleColor]
        UITabBar.appearance().tintColor = StyleHelper.tabBarIconSelectedColor

        UIPageControl.appearance().pageIndicatorTintColor = StyleHelper.pageIndicatorTintColor
        UIPageControl.appearance().currentPageIndicatorTintColor = StyleHelper.currentPageIndicatorTintColor
    }

    func shouldOpenOnboarding() -> Bool {
        return !UserDefaultsManager.sharedInstance.loadDidShowOnboarding()
    }

    // MARK: > Deep linking

    func app(app: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {

        TrackerProxy.sharedInstance.application(app, openURL: url, sourceApplication: sourceApplication, annotation: annotation)

        let ownHandling = DeepLinksRouter.sharedInstance.openUrl(url, sourceApplication: sourceApplication,
            annotation: annotation)

        let branchHandling = Branch.getInstance().handleDeepLink(url)
        let facebookHandling = FBSDKApplicationDelegate.sharedInstance().application(app, openURL: url,
            sourceApplication: sourceApplication, annotation: annotation)
        let googleHandling = GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication,
            annotation: annotation)

        return ownHandling || branchHandling || facebookHandling || googleHandling
    }
}

