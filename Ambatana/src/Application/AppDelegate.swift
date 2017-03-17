//
//  AppDelegate.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import AppsFlyerLib
import Branch
import Crashlytics
import CocoaLumberjack
import Fabric
import FBSDKCoreKit
import LGCoreKit
import RxSwift
import TwitterKit
import UIKit

#if DEBUG
    import AdSupport
#endif
import Firebase


@UIApplicationMain
final class AppDelegate: UIResponder {
    var window: UIWindow?

    fileprivate var configManager: ConfigManager?
    fileprivate var crashManager: CrashManager?
    fileprivate var keyValueStorage: KeyValueStorage?

    fileprivate var productRepository: ProductRepository?
    fileprivate var locationManager: LocationManager?
    fileprivate var sessionManager: SessionManager?
    fileprivate var featureFlags: FeatureFlaggeable?
    fileprivate var purchasesShopper: PurchasesShopper?

    fileprivate var navigator: AppNavigator?

    fileprivate let appIsActive = Variable<Bool?>(nil)
    fileprivate var didOpenApp = false
    fileprivate let disposeBag = DisposeBag()
}


// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ABTests.registerVariables()
        self.featureFlags = FeatureFlags.sharedInstance
        self.purchasesShopper = LGPurchasesShopper.sharedInstance
        setupAppearance()
        setupLibraries(application, launchOptions: launchOptions)
        self.productRepository = Core.productRepository
        self.locationManager = Core.locationManager
        self.sessionManager = Core.sessionManager
        self.configManager = ConfigManager.sharedInstance
    
        let keyValueStorage = KeyValueStorage.sharedInstance
        let versionChecker = VersionChecker.sharedInstance

        keyValueStorage[.lastRunAppVersion] = versionChecker.currentVersion.version
        keyValueStorage[.sessionNumber] += 1
        
        let crashManager = CrashManager(appCrashed: keyValueStorage[.didCrash],
                                        versionChange: VersionChecker.sharedInstance.versionChange)
        self.crashManager = crashManager
        self.keyValueStorage = keyValueStorage
        
        setupRxBindings()
        crashCheck()

        LGCoreKit.start()

        let appCoordinator = AppCoordinator(configManager: ConfigManager.sharedInstance)
        appCoordinator.delegate = self

        self.navigator = appCoordinator

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        window.rootViewController = appCoordinator.tabBarCtl
        self.window = window

        window.makeKeyAndVisible()

        let deepLinksRouter = DeepLinksRouter.sharedInstance
        let fbApplicationDelegate = FBSDKApplicationDelegate.sharedInstance()
        let deepLinksRouterContinuation = deepLinksRouter.initWithLaunchOptions(launchOptions)
        let fbSdkContinuation = fbApplicationDelegate?.application(application,
                                                                  didFinishLaunchingWithOptions: launchOptions) ?? false

        appCoordinator.open()

        return deepLinksRouterContinuation || fbSdkContinuation
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?,
                     annotation: Any) -> Bool {
        return app(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation, options: nil)
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication: String? = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation: Any? = options[UIApplicationOpenURLOptionsKey.annotation]
        return app(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation, options: options)
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        DeepLinksRouter.sharedInstance.performActionForShortcutItem(shortcutItem,
                                                                    completionHandler: completionHandler)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        /* Sent when the application is about to move from active to inactive state. This can occur for certain types
        of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application 
        and it begins the transition to the background state.
        Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
        Games should use this method to pause the game.*/
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        /*Use this method to release shared resources, save user data, invalidate timers, and store enough application 
        state information to restore your application to its current state in case it is terminated later.
        If your application supports background execution, this method is called instead of applicationWillTerminate: 
        when the user quits.*/

        keyValueStorage?[.didEnterBackground] = true
        appIsActive.value = false
        LGCoreKit.applicationDidEnterBackground()
        productRepository?.updateProductViewCounts()
        TrackerProxy.sharedInstance.applicationDidEnterBackground(application)

        // stop observing payment transactions
        if let actualFeatureFlags = featureFlags, actualFeatureFlags.pricedBumpUpEnabled {
            purchasesShopper?.stopObservingTransactions()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        /* Called as part of the transition from the background to the active state; here you can undo many of the
        changes made on entering the background.*/

        LGCoreKit.applicationWillEnterForeground()
        TrackerProxy.sharedInstance.applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        /* Restart any tasks that were paused (or not yet started) while the application was inactive.
        If the application was previously in the background, optionally refresh the user interface.*/

        keyValueStorage?[.didEnterBackground] = false
        appIsActive.value = true
        PushManager.sharedInstance.applicationDidBecomeActive(application)
        TrackerProxy.sharedInstance.applicationDidBecomeActive(application)
        navigator?.openSurveyIfNeeded()
        // observe payment transactions
        if let actualFeatureFlags = featureFlags, actualFeatureFlags.pricedBumpUpEnabled {
            purchasesShopper?.startObservingTransactions()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        Core.networkBackgroundCompletion = completionHandler
    }

    // MARK: > App continuation

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let routerUserActivity = DeepLinksRouter.sharedInstance.continueUserActivity(userActivity,
                                                                                  restorationHandler: restorationHandler)
        if #available(iOS 9.0, *) {
            AppsFlyerTracker.shared().continue(userActivity, restorationHandler: restorationHandler)
        }
        return routerUserActivity
    }


    // MARK: > Push notification

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushManager.sharedInstance.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        AppsFlyerTracker.shared().registerUninstall(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushManager.sharedInstance.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        PushManager.sharedInstance.application(application, didReceiveRemoteNotification: userInfo)
    }

    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification
        userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        PushManager.sharedInstance.application(application, handleActionWithIdentifier: identifier,
                                               forRemoteNotification: userInfo, completionHandler: completionHandler)
        DeepLinksRouter.sharedInstance.handleActionWithIdentifier(identifier, forRemoteNotification: userInfo,
                                                                  completionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        PushManager.sharedInstance.application(application, didRegisterUserNotificationSettings: notificationSettings)
    }
}


// MARK: - AppNavigatorDelegate

extension AppDelegate: AppNavigatorDelegate {
    func appNavigatorDidOpenApp() {
        didOpenApp = true
    }
}

// MARK: - Private methods
// MARK: > Setup

fileprivate extension AppDelegate {
    func setupAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.lightBarButton
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont.pageTitleFont,
                                                            NSForegroundColorAttributeName : UIColor.lightBarTitle]
        UITabBar.appearance().tintColor = UIColor.tabBarIconSelectedColor

        UIPageControl.appearance().pageIndicatorTintColor = UIColor.pageIndicatorTintColor
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.currentPageIndicatorTintColor
    }

    func setupLibraries(_ application: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {

        KeychainChecker().checkKeychain()
        LGCacheManager().cleanIfNeeded()
        let environmentHelper = EnvironmentsHelper()
        EnvironmentProxy.sharedInstance.setEnvironmentType(environmentHelper.appEnvironment)

        // Debug
        Debug.loggingOptions = [.navigation]

        #if GOD_MODE
            Debug.loggingOptions = [.navigation, .tracking, .deepLink, .monetization]
        #endif
        
        LGCoreKit.loggingOptions = [.networking, .persistence, .token, .session, .webSockets]
        if let featureFlags = featureFlags {
            LGCoreKit.shouldUseChatWithWebSocket = featureFlags.websocketChat
        }
        

        // Logging
        #if GOD_MODE
            DDLog.add(DDTTYLogger.sharedInstance())       // TTY = Xcode console
            DDTTYLogger.sharedInstance().colorsEnabled =  true
            DDLog.add(DDASLLogger.sharedInstance())       // ASL = Apple System Logs
        #endif

        // New Relic
        #if GOD_MODE
            NewRelicAgent.start(withApplicationToken: Constants.newRelicGodModeToken)
        #else
            NewRelicAgent.start(withApplicationToken: Constants.newRelicProductionToken)
        #endif
        
        // Fabric
        Twitter.sharedInstance().start(withConsumerKey: EnvironmentProxy.sharedInstance.twitterConsumerKey,
                                                      consumerSecret: EnvironmentProxy.sharedInstance.twitterConsumerSecret)
        #if DEBUG
            Fabric.with([Twitter.self])
        #else
            Fabric.with([Crashlytics.self, Twitter.self])
            Core.reporter.addReporter(CrashlyticsReporter())
            DDLog.add(CrashlyticsLogger.sharedInstance)
        #endif

        // LGCoreKit
        LGCoreKit.initialize(launchOptions, environmentType: environmentHelper.coreEnvironment)

        // Branch.io
        if let branch = Branch.getInstance() {
            branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandlerUsingBranchUniversalObject: {
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

        // Google app indexing
        FIRAppIndexing.sharedInstance().registerApp(EnvironmentProxy.sharedInstance.googleAppIndexingId)

        LGNotificationsManager.sharedInstance.setup()
        StickersManager.sharedInstance.setup()
    }
}

// MARK: > Rx

fileprivate extension AppDelegate {
    func setupRxBindings() {
        // Start location updates when app is active and indicated by sensorLocationUpdatesEnabled signal flag
        let appActive = appIsActive.asObservable().flatMap { x in
            return x.map(Observable.just) ?? Observable.empty()
        }

        // Location manager starts when app is active & has not run (not in the tour)
        let appActiveAfterTour = appActive.asObservable().distinctUntilChanged().filter { [weak self] active in
            (self?.didOpenApp ?? false)
        }
        appActiveAfterTour.subscribeNext { [weak self] enabled in
            guard let `self` = self else { return }
            if enabled {
                self.locationManager?.startSensorLocationUpdates()
            } else {
                self.locationManager?.stopSensorLocationUpdates()
            }
        }.addDisposableTo(disposeBag)

        // Force update check
        appActive.filter { $0 }.subscribeNext { [weak self] active in
            self?.configManager?.updateWithCompletion { _ in
                self?.navigator?.openForceUpdateAlertIfNeeded()
            }
        }.addDisposableTo(disposeBag)
    }
}


// MARK: > Deep linking

fileprivate extension AppDelegate {
    func app(_ app: UIApplication, openURL url: URL, sourceApplication: String?, annotation: Any?, options: [UIApplicationOpenURLOptionsKey : Any]?) -> Bool {

        TrackerProxy.sharedInstance.application(app, openURL: url, sourceApplication: sourceApplication,
                                                annotation: annotation)

        let routerHandling = DeepLinksRouter.sharedInstance.openUrl(url, sourceApplication: sourceApplication,
                                                                 annotation: annotation)

        let facebookHandling = FBSDKApplicationDelegate.sharedInstance().application(app, open: url,
                                                                                     sourceApplication: sourceApplication, annotation: annotation)
        let googleHandling = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication,
                                                                  annotation: annotation)
        if let options = options {
            AppsFlyerTracker.shared().handleOpen(url, options: options)
        } else if let sourceApplicationValue = sourceApplication {
            //We must keep it (even though it's deprecated) until we drop iOS8
            AppsFlyerTracker.shared().handleOpen(url, sourceApplication: sourceApplicationValue)
        }
        
        return routerHandling || facebookHandling || googleHandling
    }
}


// MARK: > Crash mgmt

fileprivate extension AppDelegate {
    func crashCheck() {
        guard let crashManager = crashManager else { return }
        guard let keyValueStorage = keyValueStorage else { return }

        if crashManager.shouldResetCrashFlags {
            keyValueStorage[.didCrash] = false
            keyValueStorage[.didEnterBackground] = true
        }
        if !crashManager.appCrashed && !keyValueStorage[.didEnterBackground] {
            keyValueStorage[.didCrash] = true
            crashManager.appCrashed = true
        }
    }
}
