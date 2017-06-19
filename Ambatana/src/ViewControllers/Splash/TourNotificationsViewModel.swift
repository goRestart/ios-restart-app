//
//  TourNotificationsViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum TourNotificationNextStep {
    case location
    case noStep
}

protocol TourNotificationsViewModelDelegate: BaseViewModelDelegate {
    func requestPermissionFinished()
    func requestPermissionAccepted()
}

final class TourNotificationsViewModel: BaseViewModel {

    weak var navigator: TourNotificationsNavigator?
    
    let title: String
    let subtitle: String
    let pushText: String
    let source: PrePermissionType
    let featureFlags: FeatureFlaggeable
    
    weak var delegate: TourNotificationsViewModelDelegate?
    
    var showPushInfo: Bool {
        return false
    }
    var showAlertInfo: Bool {
        return !showPushInfo
    }
    var infoImage: UIImage? {
        return UIImage(named: "img_permissions_background")
    }
    
    init(title: String, subtitle: String, pushText: String, source: PrePermissionType, featureFlags: FeatureFlags) {
        self.title = title
        self.subtitle = subtitle
        self.pushText = pushText
        self.source = source
        self.featureFlags = featureFlags
    }
    
    convenience init(title: String, subtitle: String, pushText: String, source: PrePermissionType) {
        self.init(title: title, subtitle: subtitle, pushText: pushText, source: source, featureFlags: FeatureFlags.sharedInstance)
    }

    func nextStep() -> TourNotificationNextStep? {
        guard navigator == nil else {
            navigator?.tourNotificationsFinish()
            return nil
        }
        switch source {
        case .onboarding:
            return Core.locationManager.shouldAskForLocationPermissions() ? .location : .noStep
        case .chat, .sell, .profile, .productListBanner:
            return .noStep
        }
    }

    
    // MARK: - Tracking
    
    func viewDidLoad() {
        let trackerEvent = TrackerEvent.permissionAlertStart(.push, typePage: source.trackingParam, alertType: .fullScreen,
            permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapNoButton() {
        if featureFlags.newOnboardingPhase1 {
            let actionOk = UIAction(interface: UIActionInterface.text(LGLocalizedString.onboardingAlertYes),
                                    action: { [weak self] in
                                            self?.trackCloseTourNotifications()
                                            self?.delegate?.requestPermissionFinished()
                                        
            })
            let actionCancel = UIAction(interface: UIActionInterface.text(LGLocalizedString.onboardingAlertNo),
                                        action: { [weak self] in
                                            self?.trackAskPermissions()
                                            self?.delegate?.requestPermissionAccepted()
            })
            delegate?.vmShowAlert(LGLocalizedString.onboardingNotificationsPermissionsAlertTitle,
                                  message: LGLocalizedString.onboardingNotificationsPermissionsAlertSubtitle,
                                  actions: [actionCancel, actionOk])
        } else {
            trackCloseTourNotifications()
            delegate?.requestPermissionFinished()
        }
    }
    
    func userDidTapYesButton() {
        trackAskPermissions()
        delegate?.requestPermissionFinished()
        
    }
    
    // MARK: - Private methods
    
    private func trackAskPermissions() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.push, typePage: source.trackingParam, alertType: .fullScreen,
                                                                permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    private func trackCloseTourNotifications() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.push, typePage: source.trackingParam, alertType: .fullScreen,
        permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}
