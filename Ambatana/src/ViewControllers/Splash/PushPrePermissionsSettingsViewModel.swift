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
        let trackerEvent = TrackerEvent.permissionAlertStart(.push, typePage: source.trackingParam, alertType: .fullScreen,
            permissionGoToSettings: .trueParameter)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapNoButton() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.push, typePage: source.trackingParam, alertType: .fullScreen,
            permissionGoToSettings: .trueParameter)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapYesButton() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.push, typePage: source.trackingParam, alertType: .fullScreen,
            permissionGoToSettings: .trueParameter)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}
