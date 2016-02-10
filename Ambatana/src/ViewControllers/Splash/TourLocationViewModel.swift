//
//  TourLocationViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 10/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

final class TourLocationViewModel: BaseViewModel {
    
    let typePage: EventParameterTypePage
    
    init(source: EventParameterTypePage) {
        self.typePage = source
    }
    
    
    // MARK: - Tracking
    
    func trackPermissionAlertStart() {
        let trackerEvent = TrackerEvent.permissionAlertStart(.Location, typePage: typePage, alertType: .FullScreen)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func trackPermissionAlertCancel() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.Location, typePage: typePage, alertType: .FullScreen)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func trackPermissionAlertComplete() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.Location, typePage: typePage, alertType: .FullScreen)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}