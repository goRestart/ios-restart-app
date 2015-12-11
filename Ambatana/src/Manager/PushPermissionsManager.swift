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
    public var permissionType: EventParameterPermissionType?
    public var typePage: EventParameterPermissionTypePage?
    public var alertType: EventParameterPermissionAlertType?

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
                UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsAtList()
                return false
            }

            switch (prePermissionType) {
            case .ProductList:
                guard !UserDefaultsManager.sharedInstance.loadDidAskForPushPermissionsAtList() else { return false }
            case .Chat, .Sell:
                return shouldAskForDailyPermissions()
            }
            return true
    }

    public func showPushPermissionsAlertFromViewController(viewController: UIViewController,
        prePermissionType: PrePermissionType) {

            guard shouldShowPushPermissionsAlertFromViewController(viewController, prePermissionType: prePermissionType)
                else { return }

            guard ABTests.prePermissionsActive.boolValue else {
                self.checkForSystemPushPermissions()
                return
            }

            let nativeStyleAlert = (prePermissionType == .Chat && ABTests.nativePrePermissions.boolValue)

            // tracking data
            permissionType = .Push
            typePage = prePermissionType.trackingParam
            alertType = nativeStyleAlert ? .NativeLike : .Custom

            showPermissionForViewController(viewController, prePermissionType: prePermissionType,
                isNativeStyle: nativeStyleAlert)
    }


    // MARK: - Private methods

    private func shouldAskForDailyPermissions() -> Bool {

        guard let dictPermissionsDaily = UserDefaultsManager.sharedInstance.loadDidAskForPushPermissionsDaily()
            else { return true }  // if there's no dictionary, we never asked for daily permissions
        guard let savedDate = dictPermissionsDaily[UserDefaultsManager.dailyPermissionDate] as? NSDate
            else { return false }
        guard let askTomorrow = dictPermissionsDaily[UserDefaultsManager.dailyPermissionAskTomorrow] as? Bool
            else { return false }

        let time = savedDate.timeIntervalSince1970
        let now = NSDate().timeIntervalSince1970

        let seconds = Float(now - time)
        let repeatTime = Float(Constants.pushPermissionRepeatTime)

        return seconds > repeatTime && askTomorrow
    }

    private func showPermissionForViewController(viewController: UIViewController, prePermissionType: PrePermissionType,
        isNativeStyle: Bool) {

            if isNativeStyle {
                showNativeLikePrePermissionFromViewController(viewController, prePermissionType: prePermissionType)
            } else {
                showCustomPrePermissionFromViewController(viewController, prePermissionType: prePermissionType)
            }

            // send tracking
            guard let permissionType = permissionType, let typePage = typePage, let alertType = alertType
                else { return }
            let trackerEvent = TrackerEvent.permissionAlertStart(permissionType, typePage: typePage, alertType: alertType)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    private func showNativeLikePrePermissionFromViewController(viewController: UIViewController,
        prePermissionType: PrePermissionType) {

            let alert = UIAlertController(title: prePermissionType.title,
                message: prePermissionType.message, preferredStyle: .Alert)

            let noAction = UIAlertAction(title: LGLocalizedString.commonNo, style: .Cancel, handler: { (_) -> Void in
                switch (prePermissionType) {
                case .ProductList:
                    break
                case .Chat, .Sell:
                    UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsDaily(askTomorrow:true)
                }
            })
            let yesAction = UIAlertAction(title: LGLocalizedString.commonYes, style: .Default, handler: { (_) -> Void in
                self.trackActivated()
                UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsDaily(askTomorrow:true)
                self.checkForSystemPushPermissions()
            })
            alert.addAction(noAction)
            alert.addAction(yesAction)

            viewController.presentViewController(alert, animated: true) {
                UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsAtList()
            }
    }

    private func showCustomPrePermissionFromViewController(viewController: UIViewController,
        prePermissionType: PrePermissionType) {

            let customPermissionVC = CustomPermissionViewController()

            customPermissionVC.view.frame = viewController.view.frame
            customPermissionVC.modalPresentationStyle = .OverCurrentContext
            customPermissionVC.setupCustomAlertWithTitle(prePermissionType.title, message: prePermissionType.message,
                imageName: prePermissionType.image,
                activateButtonTitle: LGLocalizedString.commonOk,
                cancelButtonTitle: LGLocalizedString.commonCancel) { (activated) in
                    if activated {
                        self.trackActivated()
                        UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsDaily(askTomorrow: true)
                        self.checkForSystemPushPermissions()
                    } else {
                        switch (prePermissionType) {
                        case .ProductList:
                            break
                        case .Chat, .Sell:
                            UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsDaily(askTomorrow: true)
                        }
                    }
            }
            UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsAtList()
            if let tabBarController = viewController.tabBarController {
                tabBarController.presentViewController(customPermissionVC, animated: false) { () -> Void in
                    customPermissionVC.showWithFadeIn()
                }
            } else {
                viewController.presentViewController(customPermissionVC, animated: false) { () -> Void in
                    customPermissionVC.showWithFadeIn()
                }
            }
    }

    private func checkForSystemPushPermissions() {
        didShowSystemPermissions = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didShowSystemPermissions:", name:UIApplicationWillResignActiveNotification, object: nil)
        askSystemForPushPermissions()
        shouldGoToSettings()
    }

    func didShowSystemPermissions(notification: NSNotification) {
        didShowSystemPermissions = true
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
    }

    /**
    In case the system permissions alert doesn't appear, we ask the user to change its permissions
    */
    private func shouldGoToSettings() {
        let _ = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "openAppSettings", userInfo: nil, repeats: false)
    }

    func openAppSettings() {

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
        guard let permissionType = permissionType, let typePage = typePage, let alertType = alertType else { return }
        let trackerEvent = TrackerEvent.permissionAlertComplete(permissionType, typePage: typePage, alertType: alertType)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

}
