//
//  PushPermissionsManager.swift
//  LetGo
//
//  Created by Dídac on 04/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public class PushPermissionsManager: NSObject {

    public static let sharedInstance: PushPermissionsManager = PushPermissionsManager()


    private var didShowSystemPermissions: Bool = false
    private var prePermissionType: PrePermissionType = .ProductList
    private var hasPrePermissions: Bool {
        return ABTests.prePermissionsActive.boolValue
    }
    private var typePage: EventParameterTypePage {
        return prePermissionType.trackingParam
    }
    private var alertType: EventParameterPermissionAlertType {
        if(prePermissionType == .ProductList && ABTests.nativePrePermissionAtList.boolValue) {
            return .NativeLike
        } else {
            return .Custom
        }
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
            case .Chat, .Sell:
                UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsDaily(askTomorrow: true)
            }

            if hasPrePermissions {
                showPermissionForViewController(viewController, prePermissionType: prePermissionType)
            } else {
                checkForSystemPushPermissions()
            }
    }

    public func application(application: UIApplication,
        didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
            if notificationSettings.types.contains(.None) {
                trackPermissionSystemCancel()
            } else {
                trackPermissionSystemComplete()
            }
    }


    // MARK: - Private methods

    private func shouldAskForListPermissions() -> Bool {
        return !UserDefaultsManager.sharedInstance.loadDidAskForPushPermissionsAtList()
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

    private func showPermissionForViewController(viewController: UIViewController, prePermissionType: PrePermissionType) {

            let completion = { [weak self] (accepted: Bool) in
                if accepted {
                    self?.trackPermissionAlertComplete()
                    self?.checkForSystemPushPermissions()
                } else {
                    self?.trackPermissionAlertCancel()
                }
            }

            trackPermissionAlertStart()

            switch alertType {
            case .Custom:
                showCustomPrePermissionFromViewController(viewController, completion: completion)
            case .NativeLike:
                showNativeLikePrePermissionFromViewController(viewController, completion: completion)
            }
    }

    private func showNativeLikePrePermissionFromViewController(viewController: UIViewController,
        completion: ((Bool)->Void)? ) {

            let alert = UIAlertController(title: prePermissionType.title,
                message: prePermissionType.message, preferredStyle: .Alert)

            let noAction = UIAlertAction(title: LGLocalizedString.commonNo, style: .Cancel) { _ in
                completion?(false)
            }
            let alertYesAction = UIAlertAction(title: LGLocalizedString.commonYes, style: .Default) { _ in
                completion?(true)
            }
            alert.addAction(noAction)
            alert.addAction(alertYesAction)

            viewController.presentViewController(alert, animated: true, completion: nil)
    }

    private func showCustomPrePermissionFromViewController(viewController: UIViewController,
        completion: ((Bool)->Void)?) {

            let customPermissionVC = CustomPermissionViewController()

            customPermissionVC.view.frame = viewController.view.frame
            customPermissionVC.modalPresentationStyle = .OverCurrentContext
            customPermissionVC.setupCustomAlertWithTitle(prePermissionType.title, message: prePermissionType.message,
                imageName: prePermissionType.image,
                activateButtonTitle: LGLocalizedString.commonOk,
                cancelButtonTitle: LGLocalizedString.commonCancel, handler: completion)
            
            if let tabBarController = viewController.tabBarController {
                tabBarController.presentViewController(customPermissionVC, animated: false) {
                    customPermissionVC.showWithFadeIn()
                }
            } else {
                viewController.presentViewController(customPermissionVC, animated: false) {
                    customPermissionVC.showWithFadeIn()
                }
            }
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

    private func trackPermissionAlertStart() {
        let trackerEvent = TrackerEvent.permissionAlertStart(.Push, typePage: typePage, alertType: alertType)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    private func trackPermissionAlertCancel() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.Push, typePage: typePage, alertType: alertType)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    private func trackPermissionAlertComplete() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.Push, typePage: typePage, alertType: alertType)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

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
