import LGCoreKit
import LGComponents

enum PrePermissionType {
    case listingListBanner
    case sell
    case chat(buyer: Bool)
    case onboarding
    case profile
}

final class LGPushPermissionsManager: PushPermissionsManager {

    static let sharedInstance: LGPushPermissionsManager = LGPushPermissionsManager()
    
    var pushPermissionsSettingsMode: Bool {
        return KeyValueStorage.sharedInstance[.pushPermissionsDidShowNativeAlert]
    }
    var pushNotificationActive: Bool {
        return UIApplication.shared.areRemoteNotificationsEnabled
    }
    private var didShowSystemPermissions: Bool = false
    private var prePermissionType: PrePermissionType = .listingListBanner
    private var typePage: EventParameterTypePage {
        return prePermissionType.trackingParam
    }

    /**
    Shows a pre permissions alert

    - parameter viewController: the VC taht will show the alert
    - parameter prePermissionType: what kind of alert will be shown
    */
    func shouldShowPushPermissionsAlertFromViewController(_ prePermissionType: PrePermissionType) -> Bool {
        // If the user is already registered for notifications, we shouldn't ask anything.
        guard !UIApplication.shared.areRemoteNotificationsEnabled else {
            return false
        }
        switch (prePermissionType) {
        case .chat:
            return shouldAskForDailyPermissions()
        case .sell, .onboarding, .profile, .listingListBanner:
            return true
        }
    }

    func showPushPermissionsAlert(prePermissionType type: PrePermissionType) {
        guard shouldShowPushPermissionsAlertFromViewController(type) else { return }
        checkForSystemPushPermissions()
    }

    func application(_ application: Application,
                     didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        guard didShowSystemPermissions else { return }

        if notificationSettings.types.contains(.alert) ||
            notificationSettings.types.contains(.badge) ||
            notificationSettings.types.contains(.sound) {
            trackPermissionSystemComplete()
        } else {
            trackPermissionSystemCancel()
        }
    }


    @discardableResult
    func showPrePermissionsViewFrom(_ viewController: UIViewController, type: PrePermissionType) -> UIViewController? {
        guard shouldShowPushPermissionsAlertFromViewController(type) else { return nil }

        prePermissionType = type

        let keyValueStorage = KeyValueStorage.sharedInstance

        // if already shown system dialog, show the view to go to settings, if not, show the normal one
        let showSettingsPrePermission = keyValueStorage[.pushPermissionsDidShowNativeAlert]
        let pushRepeateDate = Date().addingTimeInterval(SharedConstants.pushPermissionRepeatTime)

        switch prePermissionType {
        case .chat, .sell:
            keyValueStorage[.pushPermissionsDailyDate] = pushRepeateDate
        case .profile, .onboarding, .listingListBanner:
            break
        }

        if showSettingsPrePermission {
            return presentSettingsPrePermissionsFrom(viewController, type: type)
        } else {
            return presentNormalPrePermissionsFrom(viewController, type: type)
        }
    }

    private func presentNormalPrePermissionsFrom(_ viewController: UIViewController,
                                                 type: PrePermissionType) -> UIViewController {
        let wireframe = TourNotificationPushWireframe(root: viewController)
        let vc = TourNotificationsBuilder
            .modal(viewController)
            .buildTourNotification(type: type,
                                   navigator: wireframe)
        vc.modalTransitionStyle = .crossDissolve
        viewController.present(vc, animated: true, completion: nil)
        return vc
    }

    private func presentSettingsPrePermissionsFrom(_ viewController: UIViewController, type: PrePermissionType) -> UIViewController {
        let vm = PushPrePermissionsSettingsViewModel(source: type)
        let vc = PushPrePermissionsSettingsViewController(viewModel: vm)
        vc.modalTransitionStyle = .crossDissolve
        viewController.present(vc, animated: true, completion: nil)
        return vc
    }
    
    
    // MARK: - Private methods

    private func shouldAskForDailyPermissions() -> Bool {
        guard let showDate = KeyValueStorage.sharedInstance[.pushPermissionsDailyDate] else { return true }
        return showDate.timeIntervalSinceNow <= 0
    }

    private func checkForSystemPushPermissions() {
        didShowSystemPermissions = false

        /*When system alert permissions appear, application gets 'resignActive' event so we add the listener to
        check if was shown or not */
        NotificationCenter.default.addObserver(self, selector: #selector(didShowSystemPermissions(_:)),
            name:NSNotification.Name.UIApplicationWillResignActive, object: nil)
        UIApplication.shared.registerPushNotifications()

        /* Appart from listening 'resignActive' event, we need to add a Dispatch asyncAfter for the case when the alert is NOT shown */
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.settingsTimerFinished()
        }
    }

    /**
    If this method gets called it means the system show the permissions alert
    */
    @objc func didShowSystemPermissions(_ notification: Notification) {
        didShowSystemPermissions = true
        trackPermissionSystemStart()
        
        // The app just showed the Native permissions dialog
        KeyValueStorage.sharedInstance[.pushPermissionsDidShowNativeAlert] = true

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
    }

    /**
    If this method gets called it means the system DIDN'T show the permissions alert
    */
    @objc func settingsTimerFinished() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)

        /* if we reach this point, it means the app tried to show the native push permissions but it didn't,
        so we can safely say that the Native permission dialog was shown at some point before */
        KeyValueStorage.sharedInstance[.pushPermissionsDidShowNativeAlert] = true
        
        /* Only show system settings when the system doesn't ask for permission and we had a pre-permisssions question
        before*/
        guard !didShowSystemPermissions else { return }
        openPushNotificationSettings()
    }
    
    func openPushNotificationSettings() {
        guard let settingsURL = URL(string:UIApplicationOpenSettingsURLString) else { return }
        UIApplication.shared.openURL(settingsURL)
    }


    // MARK - Tracking


    private func trackPermissionSystemStart() {
        let trackerEvent = TrackerEvent.permissionSystemStart(.push, typePage: typePage)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    private func trackPermissionSystemCancel() {
        TrackerProxy.sharedInstance.setNotificationsPermission(false)

        let trackerEvent = TrackerEvent.permissionSystemCancel(.push, typePage: typePage)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    private func trackPermissionSystemComplete() {
        TrackerProxy.sharedInstance.setNotificationsPermission(true)

        let trackerEvent = TrackerEvent.permissionSystemComplete(.push, typePage: typePage)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}


// MARK: - PrePermissionType helpers

extension PrePermissionType {
    var title: String {
        switch self {
        case .onboarding:
            return R.Strings.notificationsPermissions1TitleV2
        case .chat:
            return R.Strings.notificationsPermissions3Title
        case .sell:
            return R.Strings.notificationsPermissions4Title
        case .profile, .listingListBanner:
            return R.Strings.profilePermissionsAlertTitle
        }
    }

    var subtitle: String {
        switch self {
        case .onboarding:
            return R.Strings.notificationsPermissions1Subtitle
        case .chat:
            return R.Strings.notificationsPermissions3Subtitle
        case .sell:
            return R.Strings.notificationsPermissions4Subtitle
        case .profile, .listingListBanner:
            return R.Strings.profilePermissionsAlertMessage
        }
    }

    var pushMessage: String {
        switch self {
        case .onboarding:
            return R.Strings.notificationsPermissions1Push
        case .chat:
            return R.Strings.notificationsPermissions3Push
        case .sell:
            return R.Strings.notificationsPermissions4Push
        case .profile, .listingListBanner:
            return ""
        }
    }
    
    var trackingParam: EventParameterTypePage {
        switch self {
        case .onboarding:
            return .install
        case .chat:
            return .chat
        case .sell:
            return .sell
        case .profile:
            return .profile
        case .listingListBanner:
            return .listingListBanner
        }
    }
}
