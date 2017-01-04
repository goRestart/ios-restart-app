//
//  PushPrePermissionsSettingsViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 7/3/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

final class PushPrePermissionsSettingsViewModel: BaseViewModel {
    
    let source: PrePermissionType

    var title: String {
        switch source {
        case .onboarding, .sell, .profile, .productListBanner:
            return LGLocalizedString.notificationsPermissionsSettingsTitle
        case .chat(let buyer):
            return buyer ? LGLocalizedString.notificationsPermissionsSettingsTitleChat :
                LGLocalizedString.notificationsPermissionsSettingsTitle
        }
    }

    init(source: PrePermissionType) {
        self.source = source
    }
    
    
    // MARK: - Tracking
    
    func viewDidLoad() {
        let trackerEvent = TrackerEvent.permissionAlertStart(.Push, typePage: source.trackingParam, alertType: .FullScreen,
            permissionGoToSettings: .True)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapNoButton() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.Push, typePage: source.trackingParam, alertType: .FullScreen,
            permissionGoToSettings: .True)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapYesButton() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.Push, typePage: source.trackingParam, alertType: .FullScreen,
            permissionGoToSettings: .True)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}
