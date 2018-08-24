import Foundation
import LGCoreKit
import LGComponents

enum TourNotificationNextStep {
    case location
    case noStep
}

final class TourNotificationsViewModel: BaseViewModel {

    var navigator: TourNotificationsNavigator?
    
    let title: String
    let subtitle: String
    let pushText: String
    let source: PrePermissionType
    let featureFlags: FeatureFlaggeable

    var showPushInfo: Bool { return false }
    var showAlertInfo: Bool { return !showPushInfo }
    var infoImage: UIImage? { return R.Asset.IPhoneParts.imgPermissionsBackground.image }
    
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
        case .chat, .sell, .profile, .listingListBanner:
            return .noStep
        }
    }

    
    // MARK: - Tracking
    
    func viewDidLoad() {
        let trackerEvent = TrackerEvent.permissionAlertStart(.push,
                                                             typePage: source.trackingParam,
                                                             alertType: .fullScreen,
                                                             permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func cancelAlertTapped() {
        trackCloseTourNotifications()
    }

    func okAlertTapped() {
        userDidTapYesButton()
    }

    func userDidTapYesButton() {
        requestPermissionAccepted()
        trackAskPermissions()
        requestPermissionFinished()
    }
    
    // MARK: - Private methods
    
    private func trackAskPermissions() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.push,
                                                                typePage: source.trackingParam,
                                                                alertType: .fullScreen,
                                                                permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    private func trackCloseTourNotifications() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.push,
                                                              typePage: source.trackingParam,
                                                              alertType: .fullScreen,
                                                              permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}

extension TourNotificationsViewModel {
    private func requestPermissionFinished() {
        openNextStep()
    }

    private func requestPermissionAccepted() {
        LGPushPermissionsManager.sharedInstance.showPushPermissionsAlert(prePermissionType: .onboarding)
    }

    func openNextStep() {
        guard let step = nextStep() else { return }
        switch step {
        case .location:
            navigator?.showTourLocation()
        case .noStep:
            navigator?.closeTour()
        }
    }
}
