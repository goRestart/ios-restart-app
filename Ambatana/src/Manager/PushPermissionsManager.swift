//
//  PushPermissionsManager.swift
//  LetGo
//
//  Created by Dídac on 04/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

enum PrePermissionType {
    case productListBanner
    case sell
    case chat(buyer: Bool)
    case onboarding
    case profile
}

class PushPermissionsManager: NSObject {

    static let sharedInstance: PushPermissionsManager = PushPermissionsManager()
    var pushPermissionsSettingsMode: Bool {
        return KeyValueStorage.sharedInstance[.pushPermissionsDidShowNativeAlert]
    }
    private var didShowSystemPermissions: Bool = false
    private var prePermissionType: PrePermissionType = .productListBanner
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
        case .sell, .onboarding, .profile, .productListBanner:
            return true
        }
    }

    func showPushPermissionsAlert(prePermissionType type: PrePermissionType) {
        guard shouldShowPushPermissionsAlertFromViewController(type) else { return }
        checkForSystemPushPermissions()
    }

    func application(_ application: UIApplication,
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

    func showPrePermissionsViewFrom(_ viewController: UIViewController, type: PrePermissionType,
                                           completion: (() -> ())?) -> UIViewController? {
        guard shouldShowPushPermissionsAlertFromViewController(type) else { return nil }

        prePermissionType = type

        let keyValueStorage = KeyValueStorage.sharedInstance

        // if already shown system dialog, show the view to go to settings, if not, show the normal one
        let showSettingsPrePermission = keyValueStorage[.pushPermissionsDidShowNativeAlert]
        let pushRepeateDate = Date().addingTimeInterval(Constants.pushPermissionRepeatTime)

        switch prePermissionType {
        case .chat, .sell:
            keyValueStorage[.pushPermissionsDailyDate] = pushRepeateDate
        case .profile, .onboarding, .productListBanner:
            break
        }

        if showSettingsPrePermission {
            return presentSettingsPrePermissionsFrom(viewController, type: type, completion: completion)
        } else {
            return presentNormalPrePermissionsFrom(viewController, type: type, completion: completion)
        }
    }

    private func presentNormalPrePermissionsFrom(_ viewController: UIViewController, type: PrePermissionType,
        completion: (() -> ())?) -> UIViewController {
            let vm = TourNotificationsViewModel(title: type.title, subtitle: type.subtitle, pushText: type.pushMessage,
                source: type)
            let vc = TourNotificationsViewController(viewModel: vm)
            vc.completion = completion
            viewController.present(vc, animated: true, completion: nil)
        return vc
    }

    private func presentSettingsPrePermissionsFrom(_ viewController: UIViewController, type: PrePermissionType,
                                                   completion: (() -> ())?) -> UIViewController {
        let vm = PushPrePermissionsSettingsViewModel(source: type)
        let vc = PushPrePermissionsSettingsViewController(viewModel: vm)
        vc.completion = completion
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
        NotificationCenter.default.addObserver(self, selector: #selector(PushPermissionsManager.didShowSystemPermissions(_:)),
            name:NSNotification.Name.UIApplicationWillResignActive, object: nil)
        UIApplication.shared.registerPushNotifications()

        /* Appart from listening 'resignActive' event, we need to add a timer for the case when the alert is NOT
        shown */
        let _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(PushPermissionsManager.settingsTimerFinished),
            userInfo: nil, repeats: false)
    }

    /**
    If this method gets called it means the system show the permissions alert
    */
    func didShowSystemPermissions(_ notification: Notification) {
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
    func settingsTimerFinished() {
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
        let trackerEvent = TrackerEvent.permissionSystemStart(.Push, typePage: typePage)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    private func trackPermissionSystemCancel() {
        TrackerProxy.sharedInstance.setNotificationsPermission(false)

        let trackerEvent = TrackerEvent.permissionSystemCancel(.Push, typePage: typePage)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    private func trackPermissionSystemComplete() {
        TrackerProxy.sharedInstance.setNotificationsPermission(true)

        let trackerEvent = TrackerEvent.permissionSystemComplete(.Push, typePage: typePage)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}


// MARK: - PrePermissionType helpers

extension PrePermissionType {
    var title: String {
        switch self {
        case .onboarding:
            return LGLocalizedString.notificationsPermissions1TitleV2
        case .chat:
            return LGLocalizedString.notificationsPermissions3Title
        case .sell:
            return LGLocalizedString.notificationsPermissions4Title
        case .profile, .productListBanner:
            return LGLocalizedString.profilePermissionsAlertTitle
        }
    }

    var subtitle: String {
        switch self {
        case .onboarding:
            return LGLocalizedString.notificationsPermissions1Subtitle
        case .chat:
            return LGLocalizedString.notificationsPermissions3Subtitle
        case .sell:
            return LGLocalizedString.notificationsPermissions4Subtitle
        case .profile, .productListBanner:
            return LGLocalizedString.profilePermissionsAlertMessage
        }
    }

    var pushMessage: String {
        switch self {
        case .onboarding:
            return LGLocalizedString.notificationsPermissions1Push
        case .chat:
            return LGLocalizedString.notificationsPermissions3Push
        case .sell:
            return LGLocalizedString.notificationsPermissions4Push
        case .profile, .productListBanner:
            return ""
        }
    }
    
    var trackingParam: EventParameterTypePage {
        switch self {
        case .onboarding:
            return .Install
        case .chat:
            return .chat
        case .sell:
            return .sell
        case .profile:
            return .Profile
        case .productListBanner:
            return .ProductListBanner
        }
    }
}
