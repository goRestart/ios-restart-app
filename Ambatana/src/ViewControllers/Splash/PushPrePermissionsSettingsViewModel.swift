import Foundation
import LGComponents

final class PushPrePermissionsSettingsViewModel: BaseViewModel {
    
    let source: PrePermissionType

    var title: String {
        switch source {
        case .onboarding, .sell, .profile, .listingListBanner:
            return R.Strings.notificationsPermissionsSettingsTitle
        case .chat(let buyer):
            return buyer ? R.Strings.notificationsPermissionsSettingsTitleChat :
                R.Strings.notificationsPermissionsSettingsTitle
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
