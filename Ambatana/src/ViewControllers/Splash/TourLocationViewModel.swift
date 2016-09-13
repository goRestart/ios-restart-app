//
//  TourLocationViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 10/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

enum TourLocationNextStep {
    case Posting
    case None
}

final class TourLocationViewModel: BaseViewModel {
    
    let typePage: EventParameterTypePage
    
    init(source: EventParameterTypePage) {
        self.typePage = source
    }

    func nextStep() -> TourLocationNextStep {
        return .Posting
        guard FeatureFlags.incentivizePostingMode != .Original else { return .None }
        return .Posting
    }

    // MARK: - Tracking
    
    func viewDidLoad() {
        let trackerEvent = TrackerEvent.permissionAlertStart(.Location, typePage: typePage, alertType: .FullScreen,
            permissionGoToSettings: .NotAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapNoButton() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.Location, typePage: typePage, alertType: .FullScreen,
            permissionGoToSettings: .NotAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapYesButton() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.Location, typePage: typePage, alertType: .FullScreen,
            permissionGoToSettings: .NotAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

        let trackerSystemEvent = TrackerEvent.permissionSystemStart(.Location, typePage: typePage)
        TrackerProxy.sharedInstance.trackEvent(trackerSystemEvent)
    }
}
