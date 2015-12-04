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

    /**
    Shows a pre permissions alert

    - parameter viewController: the VC taht will show the alert
    - parameter prePermissionType: what kind of alert will be shown
    */
    public func showPushPermissionsAlertFromViewController(viewController: UIViewController,
        prePermissionType: PrePermissionType) {

            guard ABTests.prePermissionsActive.boolValue else {
                PushManager.sharedInstance.askSystemForPushPermissions()
                return
            }

            let nativeStyleAlert = ((prePermissionType == .Chat && ABTests.nativePrePermissions.boolValue) || false)

            // tracking data
            permissionType = .Push
            typePage = prePermissionType.trackingParam
            alertType = nativeStyleAlert ? .NativeLike : .Custom

            switch (prePermissionType) {
            case .ProductList:
                guard !UserDefaultsManager.sharedInstance.loadDidAskForPushPermissionsAtList() else { return }
            case .Chat, .Sell:
                guard let dictPermissionsDaily = UserDefaultsManager.sharedInstance.loadDidAskForPushPermissionsDaily()
                    else {
                        showPermissionForViewController(viewController, prePermissionType: prePermissionType,
                            isNativeStyle: nativeStyleAlert)
                        return
                }
                guard let savedDate = dictPermissionsDaily[UserDefaultsManager.dailyPermissionDate] as? NSDate
                    else { return }
                guard let askTomorrow = dictPermissionsDaily[UserDefaultsManager.dailyPermissionAskTomorrow] as? Bool
                    else { return }

                let time = savedDate.timeIntervalSince1970
                let now = NSDate().timeIntervalSince1970

                let seconds = Float(now - time)
                let repeatTime = Float(Constants.pushPermissionRepeatTime)

                // if should ask in a day and asked longer tahn a day ago, ask again
                guard seconds > repeatTime && askTomorrow else { return }
            }

            showPermissionForViewController(viewController, prePermissionType: prePermissionType,
                isNativeStyle: nativeStyleAlert)
    }


    // MARK: - Private methods

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
                    UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsAtList()
                case .Chat, .Sell:
                    UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsDaily(true)
                }
            })
            let yesAction = UIAlertAction(title: LGLocalizedString.commonYes, style: .Default, handler: { (_) -> Void in
                self.trackActivated()
                PushManager.sharedInstance.askSystemForPushPermissions()
            })
            alert.addAction(noAction)
            alert.addAction(yesAction)

            viewController.presentViewController(alert, animated: true) {
                UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsAtList()
            }
    }

    private func showCustomPrePermissionFromViewController(viewController: UIViewController,
        prePermissionType: PrePermissionType) {

            guard let customPermissionView = CustomPermissionView.customPermissionView() else { return }

            customPermissionView.frame = viewController.view.frame
            customPermissionView.setupCustomAlertWithTitle(prePermissionType.title, message: prePermissionType.message,
                imageName: prePermissionType.image,
                activateButtonTitle: LGLocalizedString.commonOk,
                cancelButtonTitle: LGLocalizedString.commonCancel) { (activated) in
                    if activated {
                        self.trackActivated()
                        PushManager.sharedInstance.askSystemForPushPermissions()
                    } else {
                        switch (prePermissionType) {
                        case .ProductList:
                            UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsAtList()
                        case .Chat, .Sell:
                            UserDefaultsManager.sharedInstance.saveDidAskForPushPermissionsDaily(true)
                        }
                    }
            }
            viewController.view.addSubview(customPermissionView)
    }

    private func trackActivated() {
        guard let permissionType = permissionType, let typePage = typePage, let alertType = alertType else { return }
        let trackerEvent = TrackerEvent.permissionAlertComplete(permissionType, typePage: typePage, alertType: alertType)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}
