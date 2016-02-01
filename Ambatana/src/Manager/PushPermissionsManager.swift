//
//  PushPermissionsManager.swift
//  LetGo
//
//  Created by Dídac on 04/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public class PushPermissionsManager: NSObject {

    // Singleton
    public static let sharedInstance: PushPermissionsManager = PushPermissionsManager()

    // Tracking vars
    private let permissionType = EventParameterPermissionType.Push
    private var typePage: EventParameterTypePage?
    private var alertType: EventParameterPermissionAlertType?

    private var didShowSystemPermissions: Bool = false
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
                return !UserDefaultsManager.sharedInstance.loadDidAskForPushPermissionsAtList()
            case .Chat, .Sell:
                return shouldAskForDailyPermissions()
            }
    }

    public func showPushPermissionsAlertFromViewController(viewController: UIViewController,
        prePermissionType: PrePermissionType) {

            let nativeStyleAlert = (prePermissionType == .ProductList && ABTests.nativePrePermissionAtList.boolValue)

            // tracking data
            typePage = prePermissionType.trackingParam
            alertType = nativeStyleAlert ? .NativeLike : .Custom

            guard shouldShowPushPermissionsAlertFromViewController(viewController, prePermissionType: prePermissionType)
                else { return }

            switch (prePermissionType) {
            case .ProductList:
                UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsAtList()
            case .Chat, .Sell:
                UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsDaily(askTomorrow: true)
            }

            guard ABTests.prePermissionsActive.boolValue else {
                self.checkForSystemPushPermissions(false)
                return
            }

            showPermissionForViewController(viewController, prePermissionType: prePermissionType,
                isNativeStyle: nativeStyleAlert)
    }

    public func application(application: UIApplication,
        didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
            guard let typePage = typePage else { return }

            var trackerEvent: TrackerEvent
            TrackerProxy.sharedInstance.notificationsPermissionChanged()
            if notificationSettings.types.contains(.None) {
                trackerEvent = TrackerEvent.permissionSystemCancel(permissionType, typePage: typePage)
            } else {
                trackerEvent = TrackerEvent.permissionSystemComplete(permissionType, typePage: typePage)
            }
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }


    // MARK: - Private methods

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

    private func showPermissionForViewController(viewController: UIViewController, prePermissionType: PrePermissionType,
        isNativeStyle: Bool) {

            let yesAction = { [weak self] in
                self?.trackActivated()
                self?.checkForSystemPushPermissions(true)
            }

            if isNativeStyle {
                showNativeLikePrePermissionFromViewController(viewController, prePermissionType: prePermissionType, yesAction: yesAction)
            } else {
                showCustomPrePermissionFromViewController(viewController, prePermissionType: prePermissionType, yesAction: yesAction)
            }

            // send tracking
            guard let typePage = typePage, alertType = alertType else { return }
            let trackerEvent = TrackerEvent.permissionAlertStart(permissionType, typePage: typePage,
                alertType: alertType)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    private func showNativeLikePrePermissionFromViewController(viewController: UIViewController,
        prePermissionType: PrePermissionType, yesAction: (()->Void)? ) {

            let alert = UIAlertController(title: prePermissionType.title,
                message: prePermissionType.message, preferredStyle: .Alert)

            let noAction = UIAlertAction(title: LGLocalizedString.commonNo, style: .Cancel, handler: nil)
            let alertYesAction = UIAlertAction(title: LGLocalizedString.commonYes, style: .Default, handler: { _ in
                yesAction?()
            })
            alert.addAction(noAction)
            alert.addAction(alertYesAction)

            viewController.presentViewController(alert, animated: true, completion: nil)
    }

    private func showCustomPrePermissionFromViewController(viewController: UIViewController,
        prePermissionType: PrePermissionType, yesAction: (()->Void)?) {

            let customPermissionVC = CustomPermissionViewController()

            customPermissionVC.view.frame = viewController.view.frame
            customPermissionVC.modalPresentationStyle = .OverCurrentContext
            customPermissionVC.setupCustomAlertWithTitle(prePermissionType.title, message: prePermissionType.message,
                imageName: prePermissionType.image,
                activateButtonTitle: LGLocalizedString.commonOk,
                cancelButtonTitle: LGLocalizedString.commonCancel) { activated in
                    guard activated else { return }
                    yesAction?()
            }
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

    private func checkForSystemPushPermissions(fromPrePermissions: Bool) {
        didShowSystemPermissions = false
        if fromPrePermissions {
            /*When system alert permissions appear, application gets 'resignActive' event so we add the listener to 
            check if was shown or not */
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didShowSystemPermissions:",
                name:UIApplicationWillResignActiveNotification, object: nil)
        }
        askSystemForPushPermissions()
        if fromPrePermissions {
            /* Appart from listening 'resignActive' event, we need to add a timer for the case when the alert is NOT 
            shown */
            let _ = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "settingsTimerFinished",
                userInfo: nil, repeats: false)
        }
    }

    /**
    If this method gets called it means the system show the permissions alert
    */
    func didShowSystemPermissions(notification: NSNotification) {
        didShowSystemPermissions = true
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification,
            object: nil)
    }

    /**
    If this method gets called it means the system DIDN'T show the permissions alert
    */
    func settingsTimerFinished() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification,
            object: nil)

        guard !didShowSystemPermissions else { return }

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

    private func trackActivated() {
        guard let typePage = typePage, alertType = alertType else { return }
        let trackerEvent = TrackerEvent.permissionAlertComplete(permissionType, typePage: typePage,
            alertType: alertType)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}
