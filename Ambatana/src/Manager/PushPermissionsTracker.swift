//
//  PushPermissionTracker.swift
//  LetGo
//
//  Created by Stephen Walsh on 02/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

/*
    Use this to handle tracking calls for the Push Permissions flow
*/

struct PushPermissionsTracker {
    private let tracker: Tracker
    private let pushPermissionsManager: LGPushPermissionsManager
    
    init(tracker: Tracker = TrackerProxy.sharedInstance,
         pushPermissionsManager: LGPushPermissionsManager = LGPushPermissionsManager.sharedInstance) {
        self.tracker = tracker
        self.pushPermissionsManager = pushPermissionsManager
    }
    
    private var goToSettings: EventParameterBoolean {
        return pushPermissionsManager.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
    }
    
    func trackPushPermissionStart() {
        let trackerEvent = TrackerEvent.permissionAlertStart(.push,
                                                             typePage: .listingListBanner,
                                                             alertType: .custom,
                                                             permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }
    
    func trackPushPermissionComplete() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.push,
                                                                typePage: .listingListBanner,
                                                                alertType: .custom,
                                                                permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }
    
    func trackPushPermissionCancel() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.push,
                                                              typePage: .listingListBanner,
                                                              alertType: .custom,
                                                              permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }
}
