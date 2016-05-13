//
//  AppDelegate.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import AppsFlyer
import Branch
import Crashlytics
import CocoaLumberjack
import Fabric
import FBSDKCoreKit
import LGCoreKit
import RxSwift
import TwitterKit
import UIKit


@UIApplicationMain
final class AppDelegate: UIResponder {
    var window: UIWindow?

    var configManager: ConfigManager?
    var crashManager: CrashManager?
    var keyValueStorage: KeyValueStorage?

    private var navigator: AppNavigator?

    private let appIsActive = Variable<Bool?>(nil)
    private var didOpenApp = false
    private let disposeBag = DisposeBag()
}


// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupAppearance()
        setupLibraries(application, launchOptions: launchOptions)
        setupRxBindings()


        let configFileName = EnvironmentProxy.sharedInstance.configFileName
        let dao = LGConfigDAO(bundle: NSBundle.mainBundle(), configFileName: configFileName)
        let configManager = ConfigManager(dao: dao)
        self.configManager = configManager

        let keyValueStorage = KeyValueStorage.sharedInstance
        let versionChecker = VersionChecker.sharedInstance

        keyValueStorage[.lastRunAppVersion] = versionChecker.currentVersion.version
        let crashManager = CrashManager(appCrashed: keyValueStorage[.didCrash],
                                        versionChange: VersionChecker.sharedInstance.versionChange)
        self.crashManager = crashManager
        self.keyValueStorage = keyValueStorage

        crashCheck()

        LGCoreKit.start()

        let tabBarViewModel = TabBarViewModel()
        let tabBarController = TabBarController(viewModel: tabBarViewModel)
        let appCoordinator = AppCoordinator(tabBarController: tabBarController, configManager: configManager)
        appCoordinator.delegate = self
        tabBarViewModel.navigator = appCoordinator

        self.navigator = appCoordinator

        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = tabBarController
        self.window = window

        window.makeKeyAndVisible()
        appCoordinator.open()

        let deepLinksRouter = DeepLinksRouter.sharedInstance
        let fbApplicationDelegate = FBSDKApplicationDelegate.sharedInstance()
        let deepLinksRouterContinuation = deepLinksRouter.initWithLaunchOptions(launchOptions)
        let fbSdkContinuation = fbApplicationDelegate.application(application,
                                                                  didFinishLaunchingWithOptions: launchOptions)
        return deepLinksRouterContinuation || fbSdkContinuation
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,
                     annotation: AnyObject) -> Bool {
            return app(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    @available(iOS 9.0, *)
    func application(application: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let sourceApplication: String? = options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String
        let annotation: AnyObject? = options[UIApplicationOpenURLOptionsAnnotationKey]
        return app(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem,
                     completionHandler: (Bool) -> Void) {
        DeepLinksRouter.sharedInstance.performActionForShortcutItem(shortcutItem,
                                                                    completionHandler: completionHandler)
    }

    func applicationWillResignActive(application: UIApplication) {
        /* Sent when the application is about to move from active to inactive state. This can occur for certain types
        of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application 
        and it begins the transition to the background state.
        Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
        Games should use this method to pause the game.*/
    }

    func applicationDidEnterBackground(application: UIApplication) {
        /*Use this method to release shared resources, save user data, invalidate timers, and store enough application 
        state information to restore your application to its current state in case it is terminated later.
        If your application supports background execution, this method is called instead of applicationWillTerminate: 
        when the user quits.*/

        keyValueStorage?[.didEnterBackground] = true
        appIsActive.value = false
        TrackerProxy.sharedInstance.applicationDidEnterBackground(application)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        /* Called as part of the transition from the background to the active state; here you can undo many of the
        changes made on entering the background.*/

        LGCoreKit.refreshData()
        TrackerProxy.sharedInstance.applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        /* Restart any tasks that were paused (or not yet started) while the application was inactive.
        If the application was previously in the background, optionally refresh the user interface.*/

        keyValueStorage?[.didEnterBackground] = false
        appIsActive.value = true
        TrackerProxy.sharedInstance.applicationDidBecomeActive(application)
    }

    func applicationWillTerminate(application: UIApplication) {

    }

    // MARK: > App continuation

    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity,
                     restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        let ownUserActivity = DeepLinksRouter.sharedInstance.continueUserActivity(userActivity,
                                                                                  restorationHandler: restorationHandler)
        let branchUserActivity = Branch.getInstance().continueUserActivity(userActivity)
        if #available(iOS 9.0, *) {
            AppsFlyerTracker.sharedTracker().continueUserActivity(userActivity, restorationHandler: restorationHandler)
        }
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

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification
        userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        PushManager.sharedInstance.application(application, handleActionWithIdentifier: identifier,
                                               forRemoteNotification: userInfo, completionHandler: completionHandler)
        DeepLinksRouter.sharedInstance.handleActionWithIdentifier(identifier, forRemoteNotification: userInfo,
                                                                  completionHandler: completionHandler)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
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

private extension AppDelegate {
    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = StyleHelper.navBarButtonsColor
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : StyleHelper.navBarTitleFont,
                                                            NSForegroundColorAttributeName : StyleHelper.navBarTitleColor]
        UITabBar.appearance().tintColor = StyleHelper.tabBarIconSelectedColor

        UIPageControl.appearance().pageIndicatorTintColor = StyleHelper.pageIndicatorTintColor
        UIPageControl.appearance().currentPageIndicatorTintColor = StyleHelper.currentPageIndicatorTintColor
    }

    private func setupLibraries(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
        let environmentHelper = EnvironmentsHelper()
        EnvironmentProxy.sharedInstance.setEnvironmentType(environmentHelper.appEnvironment)

        // Debug
        Debug.loggingOptions = [AppLoggingOptions.Navigation]
        LGCoreKit.loggingOptions = [CoreLoggingOptions.Networking, CoreLoggingOptions.Persistence,
                                    CoreLoggingOptions.Token, CoreLoggingOptions.Session, CoreLoggingOptions.WebSockets]
        LGCoreKit.activateWebsocket = FeatureFlags.websocketChat

        // Logging
        #if GOD_MODE
            DDLog.addLogger(DDTTYLogger.sharedInstance())       // TTY = Xcode console
            DDTTYLogger.sharedInstance().colorsEnabled =  true
            DDLog.addLogger(DDASLLogger.sharedInstance())       // ASL = Apple System Logs
        #endif
        DDLog.addLogger(CrashlyticsLogger.sharedInstance)

        // Fabric
        Twitter.sharedInstance().startWithConsumerKey(EnvironmentProxy.sharedInstance.twitterConsumerKey,
                                                      consumerSecret: EnvironmentProxy.sharedInstance.twitterConsumerSecret)
        #if DEBUG
            Fabric.with([Twitter.self])
        #else
            Fabric.with([Crashlytics.self, Twitter.self])
        #endif

        // LGCoreKit
        LGCoreKit.initialize(launchOptions, environmentType: environmentHelper.coreEnvironment)
        Core.reporter.addReporter(CrashlyticsReporter())

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

        // Google app indexing
        GSDAppIndexing.sharedInstance().registerApp(EnvironmentProxy.sharedInstance.googleAppIndexingId)

        CommercializerManager.sharedInstance.setup()
        NotificationsManager.sharedInstance.setup()
    }
}

// MARK: > Rx

private extension AppDelegate {
    func setupRxBindings() {

        // Start location updates when app is active and indicated by sensorLocationUpdatesEnabled signal flag
        let appActive = appIsActive.asObservable().flatMap { x in
            return x.map(Observable.just) ?? Observable.empty()
        }

        // Location manager starts when  when opening the app
        appActive.asObservable().filter { [weak self] active in
            (self?.didOpenApp ?? false)
        }.subscribeNext { enabled in
            let locationManager = Core.locationManager
            if enabled {
                locationManager.startSensorLocationUpdates()
            } else {
                locationManager.stopSensorLocationUpdates()
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

private extension AppDelegate {
    func app(app: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {

        TrackerProxy.sharedInstance.application(app, openURL: url, sourceApplication: sourceApplication,
                                                annotation: annotation)

        let ownHandling = DeepLinksRouter.sharedInstance.openUrl(url, sourceApplication: sourceApplication,
                                                                 annotation: annotation)

        let branchHandling = Branch.getInstance().handleDeepLink(url)
        let facebookHandling = FBSDKApplicationDelegate.sharedInstance().application(app, openURL: url,
                                                                                     sourceApplication: sourceApplication, annotation: annotation)
        let googleHandling = GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication,
                                                                  annotation: annotation)
        AppsFlyerTracker.sharedTracker().handleOpenURL(url, sourceApplication: sourceApplication,
                                                       withAnnotation: annotation)
        
        return ownHandling || branchHandling || facebookHandling || googleHandling
    }
}


// MARK: > Crash mgmt

private extension AppDelegate {
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
