//
//  TourLocationViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 10/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

final class TourLocationViewModel: BaseViewModel {

    var title: String {
        switch FeatureFlags.onboardinPermissionsMode {
        case .Original, .OneButtonOriginalImages:
            return LGLocalizedString.locationPermissionsTitle
        case .OneButtonNewImages:
            return LGLocalizedString.locationPermissionsTitleV2

        }
    }
    var showBubbleInfo: Bool {
        switch FeatureFlags.onboardinPermissionsMode {
        case .Original, .OneButtonOriginalImages:
            return true
        case .OneButtonNewImages:
            return false
        }
    }
    var showAlertInfo: Bool {
        return !showBubbleInfo
    }
    var infoImage: UIImage? {
        switch FeatureFlags.onboardinPermissionsMode {
        case .Original, .OneButtonOriginalImages:
            return UIImage(named: "img_notifications")
        case .OneButtonNewImages:
            return UIImage(named: "img_permissions_background")
        }
    }
    var showNoButton: Bool {
        switch FeatureFlags.onboardinPermissionsMode {
        case .Original:
            return true
        case .OneButtonNewImages, .OneButtonOriginalImages:
            return false
        }
    }
    
    let typePage: EventParameterTypePage

    weak var navigator: TourLocationNavigator?
    
    init(source: EventParameterTypePage) {
        self.typePage = source
    }

    func nextStep() {
        navigator?.tourLocationFinish()
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
