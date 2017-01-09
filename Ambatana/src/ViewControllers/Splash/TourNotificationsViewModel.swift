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

final class TourNotificationsViewModel: BaseViewModel {

    weak var navigator: TourNotificationsNavigator?
    
    let title: String
    let subtitle: String
    let pushText: String
    let source: PrePermissionType
    var showPushInfo: Bool {
        return false
    }
    var showAlertInfo: Bool {
        return !showPushInfo
    }
    var infoImage: UIImage? {
        return UIImage(named: "img_permissions_background")
    }
    
    init(title: String, subtitle: String, pushText: String, source: PrePermissionType) {
        self.title = title
        self.subtitle = subtitle
        self.pushText = pushText
        self.source = source
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
        let trackerEvent = TrackerEvent.permissionAlertCancel(.push, typePage: source.trackingParam, alertType: .fullScreen,
            permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapYesButton() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.push, typePage: source.trackingParam, alertType: .fullScreen,
            permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}
