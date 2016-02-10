//
//  TourNotificationsViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

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

    
    // MARK: - Tracking
    
    func trackPermissionAlertStart() {
        let trackerEvent = TrackerEvent.permissionAlertStart(.Push, typePage: typePage, alertType: .FullScreen)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func trackPermissionAlertCancel() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.Push, typePage: typePage, alertType: .FullScreen)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func trackPermissionAlertComplete() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.Push, typePage: typePage, alertType: .FullScreen)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}