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
    case Location
    case None
}

final class TourNotificationsViewModel: BaseViewModel {
    
    let title: String
    let subtitle: String
    let pushText: String
    let typePage: EventParameterTypePage
    
    init(title: String, subtitle: String, pushText: String, source: EventParameterTypePage) {
        self.title = title
        self.subtitle = subtitle
        self.pushText = pushText
        self.typePage = source
    }

    func nextStep() -> TourNotificationNextStep {
        if typePage == .Install && Core.locationManager.shouldAskForLocationPermissions() {
            return .Location
        } else {
            return .None
        }
    }
    
    // MARK: - Tracking
    
    func viewDidLoad() {
        let trackerEvent = TrackerEvent.permissionAlertStart(.Push, typePage: typePage, alertType: .FullScreen)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapNoButton() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.Push, typePage: typePage, alertType: .FullScreen)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapYesButton() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.Push, typePage: typePage, alertType: .FullScreen)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}