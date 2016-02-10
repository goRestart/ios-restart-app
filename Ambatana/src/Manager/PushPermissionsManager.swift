//
//  PushPermissionsManager.swift
//  LetGo
//
//  Created by Dídac on 04/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public enum PrePermissionType: Int {
    case ProductList
    case Sell
    case Chat
    case Onboarding
}

public class PushPermissionsManager: NSObject {

    public static let sharedInstance: PushPermissionsManager = PushPermissionsManager()
    var shouldAskForPermissionsOnCurrentSession: Bool = true
    private var didShowSystemPermissions: Bool = false
    private var prePermissionType: PrePermissionType = .ProductList
    private var hasPrePermissions: Bool {
        return ABTests.prePermissionsActive.boolValue
    }
    private var typePage: EventParameterTypePage {
        return prePermissionType.trackingParam
    }

    /**
    Shows a pre permissions alert

    - parameter viewController: the VC taht will show the alert
    - parameter prePermissionType: what kind of alert will be shown
    */
    public func shouldShowPushPermissionsAlertFromViewController(viewController: UIViewController,
        prePermissionType: PrePermissionType) -> Bool {

            // If the user is already registered for notifications, we shouldn't ask anything.
            guard !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() else {
                return false
            }
            switch (prePermissionType) {
            case .ProductList:
                return shouldAskForListPermissions()
            case .Chat, .Sell:
                return shouldAskForDailyPermissions()
            case .Onboarding:
                return true
            }
    }
    
    public func showPushPermissionsAlertFromViewController(viewController: UIViewController,
        prePermissionType: PrePermissionType) {
            
            guard shouldShowPushPermissionsAlertFromViewController(viewController, prePermissionType: prePermissionType)
                else { return }
            
            self.prePermissionType = prePermissionType
            
            switch (prePermissionType) {
            case .ProductList:
                UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsAtList()
            case .Chat, .Sell, .Onboarding:
                UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsDaily(askTomorrow: true)
            }
            
            checkForSystemPushPermissions()
            
    }
    
    public func application(application: UIApplication,
        didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
            if notificationSettings.types.contains(.Alert) ||
                notificationSettings.types.contains(.Badge) ||
                notificationSettings.types.contains(.Sound) {
                    trackPermissionSystemComplete()
            } else {
                trackPermissionSystemCancel()
            }
    }


    // MARK: - Private methods

    private func shouldAskForListPermissions() -> Bool {
        return !UserDefaultsManager.sharedInstance.loadDidAskForPushPermissionsAtList() && shouldAskForPermissionsOnCurrentSession
    }

    private func shouldAskForDailyPermissions() -> Bool {

        guard let savedDate = UserDefaultsManager.sharedInstance.loadDidAskForPushPermissionsDailyDate() else {
            return true
        }
        guard let askTomorrow = UserDefaultsManager.sharedInstance.loadDidAskForPushPermissionsDailyAskTomorrow() else {
            return true
        }

        let time = savedDate.timeIntervalSince1970
        let now = NSDate().timeIntervalSince1970

        let seconds = Float(now - time)
        let repeatTime = Float(Constants.pushPermissionRepeatTime)

        return seconds > repeatTime && askTomorrow
    }

    private func checkForSystemPushPermissions() {
        didShowSystemPermissions = false

        /*When system alert permissions appear, application gets 'resignActive' event so we add the listener to
        check if was shown or not */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didShowSystemPermissions:",
            name:UIApplicationWillResignActiveNotification, object: nil)
        askSystemForPushPermissions()

        /* Appart from listening 'resignActive' event, we need to add a timer for the case when the alert is NOT
        shown */
        let _ = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "settingsTimerFinished",
            userInfo: nil, repeats: false)
    }

    /**
    If this method gets called it means the system show the permissions alert
    */
    func didShowSystemPermissions(notification: NSNotification) {
        didShowSystemPermissions = true
        trackPermissionSystemStart()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification,
            object: nil)
    }

    /**
    If this method gets called it means the system DIDN'T show the permissions alert
    */
    func settingsTimerFinished() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification,
            object: nil)

        /* Only show system settings when the system doesn't ask for permission and we had a pre-permisssions question
        before*/
        guard !didShowSystemPermissions && hasPrePermissions else { return }

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
        TrackerProxy.sharedInstance.notificationsPermissionChanged()

        let trackerEvent = TrackerEvent.permissionSystemCancel(.Push, typePage: typePage)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    private func trackPermissionSystemComplete() {
        TrackerProxy.sharedInstance.notificationsPermissionChanged()

        let trackerEvent = TrackerEvent.permissionSystemComplete(.Push, typePage: typePage)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}


// MARK: - PrePermissionType helpers

extension PrePermissionType {
    public var title: String {
        switch (self) {
        case ProductList:
            return ABTests.alternativePermissionText.boolValue ?
                LGLocalizedString.customPermissionListTitleB : LGLocalizedString.customPermissionListTitleA
        case Sell:
            return LGLocalizedString.customPermissionSellTitle
        case Chat:
            return LGLocalizedString.customPermissionChatTitle
        case Onboarding:
            return ""
        }
    }

    public var message: String {
        switch (self) {
        case ProductList:
            return ABTests.alternativePermissionText.boolValue ?
                LGLocalizedString.customPermissionListMessageB : LGLocalizedString.customPermissionListMessageA
        case Sell:
            return LGLocalizedString.customPermissionSellMessage
        case Chat:
            return LGLocalizedString.customPermissionChatMessage
        case Onboarding:
            return ""
        }
    }

    public var image: String {
        switch (self) {
        case ProductList:
            return "custom_permission_list"
        case Sell:
            return "custom_permission_sell"
        case Chat:
            return "custom_permission_chat"
        case Onboarding:
            return ""
        }
    }
    
    public var trackingParam: EventParameterTypePage {
        switch (self) {
        case ProductList:
            return .ProductList
        case Sell:
            return .Sell
        case Chat:
            return .Chat
        case Onboarding:
            return .Install
        }
    }
}
