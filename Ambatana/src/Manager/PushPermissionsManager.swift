//
//  PushPermissionsManager.swift
//  LetGo
//
//  Created by Dídac on 04/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public enum PrePermissionType {
    case ProductList
    case Sell
    case Chat(buyer: Bool)
    case Onboarding
    case Profile
}

public class PushPermissionsManager: NSObject {

    public static let sharedInstance: PushPermissionsManager = PushPermissionsManager()
    var shouldAskForListPermissionsOnCurrentSession: Bool = true
    var pushPermissionsSettingsMode: Bool {
        return KeyValueStorage.sharedInstance[.pushPermissionsDidShowNativeAlert]
    }
    private var didShowSystemPermissions: Bool = false
    private var prePermissionType: PrePermissionType = .ProductList
    private var typePage: EventParameterTypePage {
        return prePermissionType.trackingParam
    }

    /**
    Shows a pre permissions alert

    - parameter viewController: the VC taht will show the alert
    - parameter prePermissionType: what kind of alert will be shown
    */
    public func shouldShowPushPermissionsAlertFromViewController(prePermissionType: PrePermissionType) -> Bool {
        // If the user is already registered for notifications, we shouldn't ask anything.
        guard !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() else {
            return false
        }
        switch (prePermissionType) {
        case .ProductList:
            return shouldAskForListPermissions()
        case .Chat:
            return shouldAskForDailyPermissions()
        case .Sell, .Onboarding, .Profile:
            return true
        }
    }

    public func showPushPermissionsAlert(prePermissionType type: PrePermissionType) {
        guard shouldShowPushPermissionsAlertFromViewController(type) else { return }
        checkForSystemPushPermissions()
    }

    public func application(application: UIApplication,
                            didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        guard didShowSystemPermissions else { return }

        if notificationSettings.types.contains(.Alert) ||
            notificationSettings.types.contains(.Badge) ||
            notificationSettings.types.contains(.Sound) {
            trackPermissionSystemComplete()
        } else {
            trackPermissionSystemCancel()
        }
    }

    public func showPrePermissionsViewFrom(viewController: UIViewController, type: PrePermissionType,
                                           completion: (() -> ())?) -> UIViewController? {
        guard shouldShowPushPermissionsAlertFromViewController(type) else { return nil }

        prePermissionType = type

        let keyValueStorage = KeyValueStorage.sharedInstance

        // if already shown system dialog, show the view to go to settings, if not, show the normal one
        let showSettingsPrePermission = keyValueStorage[.pushPermissionsDidShowNativeAlert]
        let pushRepeateDate = NSDate().dateByAddingTimeInterval(Constants.pushPermissionRepeatTime)

        switch prePermissionType {
        case .ProductList:
            keyValueStorage[.pushPermissionsDidAskAtList] = true
        case .Chat, .Sell:
            keyValueStorage[.pushPermissionsDailyDate] = pushRepeateDate
        case .Profile, .Onboarding:
            break
        }

        if showSettingsPrePermission {
            return presentSettingsPrePermissionsFrom(viewController, type: type)
        } else {
            return presentNormalPrePermissionsFrom(viewController, type: type, completion: completion)
        }
    }

    private func presentNormalPrePermissionsFrom(viewController: UIViewController, type: PrePermissionType,
        completion: (() -> ())?) -> UIViewController {
            let vm = TourNotificationsViewModel(title: type.title, subtitle: type.subtitle, pushText: type.pushMessage,
                source: type)
            let vc = TourNotificationsViewController(viewModel: vm)
            vc.completion = completion
            viewController.presentViewController(vc, animated: true, completion: nil)
        return vc
    }
    
    private func presentSettingsPrePermissionsFrom(viewController: UIViewController, type: PrePermissionType) -> UIViewController {
        let vm = PushPrePermissionsSettingsViewModel(source: type)
        let vc = PushPrePermissionsSettingsViewController(viewModel: vm)
        viewController.presentViewController(vc, animated: true, completion: nil)
        return vc
    }
    
    
    // MARK: - Private methods

    private func shouldAskForListPermissions() -> Bool {
        return !KeyValueStorage.sharedInstance[.pushPermissionsDidAskAtList] && shouldAskForListPermissionsOnCurrentSession
    }

    private func shouldAskForDailyPermissions() -> Bool {
        guard let showDate = KeyValueStorage.sharedInstance[.pushPermissionsDailyDate] else { return true }
        return showDate.timeIntervalSinceNow <= 0
    }

    private func checkForSystemPushPermissions() {
        didShowSystemPermissions = false

        /*When system alert permissions appear, application gets 'resignActive' event so we add the listener to
        check if was shown or not */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PushPermissionsManager.didShowSystemPermissions(_:)),
            name:UIApplicationWillResignActiveNotification, object: nil)
        askSystemForPushPermissions()

        /* Appart from listening 'resignActive' event, we need to add a timer for the case when the alert is NOT
        shown */
        let _ = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(PushPermissionsManager.settingsTimerFinished),
            userInfo: nil, repeats: false)
    }

    /**
    If this method gets called it means the system show the permissions alert
    */
    func didShowSystemPermissions(notification: NSNotification) {
        didShowSystemPermissions = true
        trackPermissionSystemStart()
        
        // The app just showed the Native permissions dialog
        KeyValueStorage.sharedInstance[.pushPermissionsDidShowNativeAlert] = true

        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification,
            object: nil)
    }

    /**
    If this method gets called it means the system DIDN'T show the permissions alert
    */
    func settingsTimerFinished() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification,
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
        guard let settingsURL = NSURL(string:UIApplicationOpenSettingsURLString) else { return }
        UIApplication.sharedApplication().openURL(settingsURL)
    }

    private func askSystemForPushPermissions() {
        let application = UIApplication.sharedApplication()
        let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert,
            UIUserNotificationType.Badge, UIUserNotificationType.Sound])
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
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
    public var title: String {
        switch self {
        case Onboarding:
            return LGLocalizedString.notificationsPermissions1Title
        case ProductList:
            return LGLocalizedString.notificationsPermissions2Title
        case Chat:
            return LGLocalizedString.notificationsPermissions3Title
        case Sell:
            return LGLocalizedString.notificationsPermissions4Title
        case .Profile:
            return LGLocalizedString.profilePermissionsAlertTitle
        }
    }

    public var subtitle: String {
        switch self {
        case Onboarding:
            return LGLocalizedString.notificationsPermissions1Subtitle
        case ProductList:
            return LGLocalizedString.notificationsPermissions1Subtitle
        case Chat:
            return LGLocalizedString.notificationsPermissions3Subtitle
        case Sell:
            return LGLocalizedString.notificationsPermissions4Subtitle
        case Profile:
            return LGLocalizedString.profilePermissionsAlertMessage
        }
    }

    public var pushMessage: String {
        switch self {
        case Onboarding:
            return LGLocalizedString.notificationsPermissions1Push
        case ProductList:
            return LGLocalizedString.notificationsPermissions1Push
        case Chat:
            return LGLocalizedString.notificationsPermissions3Push
        case Sell:
            return LGLocalizedString.notificationsPermissions4Push
        case Profile:
            return ""
        }
    }
    
    public var trackingParam: EventParameterTypePage {
        switch self {
        case Onboarding:
            return .Install
        case ProductList:
            return .ProductList
        case Chat:
            return .Chat
        case Sell:
            return .Sell
        case Profile:
            return .Profile
        }
    }
}
