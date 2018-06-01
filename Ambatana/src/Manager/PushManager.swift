//
//  PushManager.swift
//  LetGo
//
//  Created by Albert Hernández López on 28/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Leanplum
import JWT

final class PushManager {
    enum Notification: String {
        case DidRegisterUserNotificationSettings
    }

    static let sharedInstance: PushManager = PushManager(navigator: nil)

    private let pushPermissionManager: PushPermissionsManager
    private let installationRepository: InstallationRepository
    private let deepLinksRouter: DeepLinksRouter
    private let notificationsManager: NotificationsManager
    private let locationRepository: LocationRepository
    private let featureFlags: FeatureFlaggeable
    private let keyValueStorage: KeyValueStorage
    private let navigator: AppNavigator?


    struct TrustAndSafety {
        static let backgroundLocationTimeout: Double = 20
        static let emergencyLocateKey = "emergency-locate"
        static let offensiveReportKey = "offensive-report"
    }

    // MARK: - Lifecycle

    convenience init(navigator: AppNavigator?) {
        self.init(pushPermissionManager: LGPushPermissionsManager.sharedInstance,
                  installationRepository: Core.installationRepository,
                  deepLinksRouter: LGDeepLinksRouter.sharedInstance,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  locationRepository: Core.locationRepository,
                  featureFlags: FeatureFlags.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  navigator: navigator)
    }

    required init(pushPermissionManager: PushPermissionsManager,
                  installationRepository: InstallationRepository,
                  deepLinksRouter: DeepLinksRouter,
                  notificationsManager: NotificationsManager,
                  locationRepository: LocationRepository,
                  featureFlags: FeatureFlaggeable,
                  keyValueStorage: KeyValueStorage,
                  navigator: AppNavigator?) {
        self.pushPermissionManager = pushPermissionManager
        self.installationRepository = installationRepository
        self.deepLinksRouter = deepLinksRouter
        self.notificationsManager = notificationsManager
        self.locationRepository = locationRepository
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        self.navigator = navigator
    }


    // MARK: - Internal methods

    func application(_ application: Application,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        // Setup push notification libraries
        setupLeanplum()
    }

    func applicationDidBecomeActive(_ application: Application) {
        /* If push notification alert was already shown, then call `registerForRemoteNotifications` again
         so the app delegate method will be called back again and update `Installation` (if needed) in:
         `application(application:didRegisterForRemoteNotificationsWithDeviceToken:) */
        if application.areRemoteNotificationsEnabled {
            application.registerForRemoteNotifications()
        } else {
            installationRepository.updatePushToken("", completion: nil)
        }

        if keyValueStorage[.showOffensiveReportOnNextStart] {
            showOffensiveReportAlert()
        }
    }

    func application(_ application: Application,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        let emergency = userInfo[TrustAndSafety.emergencyLocateKey] as? Int
        let offensiveReport = userInfo[TrustAndSafety.offensiveReportKey] as? Int

        if let _ = emergency {
            startEmergencyLocate { completionHandler(.noData) }
        } else if let _ = offensiveReport {
            if application.applicationState == .active {
                showOffensiveReportAlert()
            } else {
                keyValueStorage[.showOffensiveReportOnNextStart] = true
            }
        } else {
            deepLinksRouter.didReceiveRemoteNotification(userInfo,
                                                         applicationState: application.applicationState)
            notificationsManager.updateCounters()
        }
    }

    func application(_ application: Application,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        installationRepository.updatePushToken(tokenStringFromData(deviceToken), completion: nil)
    }

    func application(_ application: Application,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
        installationRepository.updatePushToken("", completion: nil)
    }

    func application(_ application: Application, handleActionWithIdentifier identifier: String?,
                     forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        Leanplum.handleAction(withIdentifier: identifier, forRemoteNotification: userInfo, completionHandler: completionHandler)
    }

    func application(_ application: Application,
                     didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NotificationCenter.default
            .post(name: Foundation.Notification.Name(rawValue: Notification.DidRegisterUserNotificationSettings.rawValue),
                  object: nil)
        pushPermissionManager.application(application, didRegisterUserNotificationSettings: notificationSettings)
    }


    // MARK: - Private methods

    private func setupLeanplum() {
        let environmentHelper = EnvironmentsHelper()
        switch environmentHelper.appEnvironment {
        case .production:
            Leanplum.setAppId(EnvironmentProxy.sharedInstance.leanplumAppId,
                              withProductionKey: EnvironmentProxy.sharedInstance.leanplumEnvKey)
        case .development, .escrow:
            Leanplum.setAppId(EnvironmentProxy.sharedInstance.leanplumAppId,
                              withDevelopmentKey:EnvironmentProxy.sharedInstance.leanplumEnvKey)
        }
    }

    private func tokenStringFromData(_ data: Data) -> String {
        return data.hexString
    }

    private func startEmergencyLocate(completion: @escaping () -> Void) {
        self.locationRepository.startEmergencyLocation()
        let deadline = DispatchTime.now() + TrustAndSafety.backgroundLocationTimeout
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
            self.locationRepository.stopEmergencyLocation()
            completion()
        })
    }

    private func showOffensiveReportAlert() {
        guard featureFlags.offensiveReportAlert.isActive else { return }
        if let navigator = navigator, navigator.canOpenOffensiveReportAlert() {
            navigator.openOffensiveReportAlert()
            keyValueStorage[.showOffensiveReportOnNextStart] = false
        } else {
            keyValueStorage[.showOffensiveReportOnNextStart] = true
        }
    }
}
