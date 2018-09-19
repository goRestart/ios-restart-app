import LGCoreKit
import Leanplum
import JWT
import LGComponents

final class PushManager {
    enum Notification: String {
        case DidRegisterUserNotificationSettings
    }

    private let pushPermissionManager: PushPermissionsManager
    private let installationRepository: InstallationRepository
    private let deepLinksRouter: DeepLinksRouter
    private let notificationsManager: NotificationsManager
    private let locationRepository: LocationRepository
    private let featureFlags: FeatureFlaggeable
    private let keyValueStorage: KeyValueStorageable
    weak var navigator: AppNavigator?


    struct TrustAndSafety {
        static let backgroundLocationTimeout: Double = 20
        static let emergencyLocateKey = "emergency-locate"
        static let offensiveReportKey = "offensive-report"
        static let verificationCampaign = "verification-campaign"
    }

    // MARK: - Lifecycle

    convenience init() {
        self.init(pushPermissionManager: LGPushPermissionsManager.sharedInstance,
                  installationRepository: Core.installationRepository,
                  deepLinksRouter: LGDeepLinksRouter.sharedInstance,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  locationRepository: Core.locationRepository,
                  featureFlags: FeatureFlags.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance)
    }

    required init(pushPermissionManager: PushPermissionsManager,
                  installationRepository: InstallationRepository,
                  deepLinksRouter: DeepLinksRouter,
                  notificationsManager: NotificationsManager,
                  locationRepository: LocationRepository,
                  featureFlags: FeatureFlaggeable,
                  keyValueStorage: KeyValueStorageable) {
        self.pushPermissionManager = pushPermissionManager
        self.installationRepository = installationRepository
        self.deepLinksRouter = deepLinksRouter
        self.notificationsManager = notificationsManager
        self.locationRepository = locationRepository
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
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

        if keyValueStorage[.showVerificationAwarenessOnNextStart] {
            showVerificationAwarenessView()
        }
    }

    func application(_ application: Application,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        let emergency = userInfo[TrustAndSafety.emergencyLocateKey] as? Int
        let offensiveReport = userInfo[TrustAndSafety.offensiveReportKey] as? Int
        let verificationCampaign = userInfo[TrustAndSafety.verificationCampaign] as? Int

        if let _ = emergency {
            startEmergencyLocate { completionHandler(.noData) }
        } else if let _ = offensiveReport {
            if application.applicationState == .active {
                showOffensiveReportAlert()
            } else {
                keyValueStorage[.showOffensiveReportOnNextStart] = true
            }
        } else if let _  = verificationCampaign {
            if application.applicationState == .active {
                showVerificationAwarenessView()
            } else {
                keyValueStorage[.showVerificationAwarenessOnNextStart] = true
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
        #if GOD_MODE
            let godmode = true
        #else
            let godmode = false
        #endif
        let environmentHelper = EnvironmentsHelper(godmode: godmode)
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
        if let navigator = navigator, navigator.canOpenModalView() {
            navigator.openOffensiveReportAlert()
            keyValueStorage[.showOffensiveReportOnNextStart] = false
        } else {
            keyValueStorage[.showOffensiveReportOnNextStart] = true
        }
    }

    private func showVerificationAwarenessView() {
        guard featureFlags.advancedReputationSystem12.isActive else { return }
        guard let navigator = navigator, navigator.shouldShowVerificationAwareness() else { return }
        if navigator.canOpenModalView() {
            navigator.openVerificationAwarenessView()
            keyValueStorage[.showVerificationAwarenessOnNextStart] = false
        } else {
            keyValueStorage[.showVerificationAwarenessOnNextStart] = true
        }
    }
}
