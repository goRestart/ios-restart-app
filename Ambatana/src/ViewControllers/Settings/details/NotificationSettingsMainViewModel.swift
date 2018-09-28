import LGCoreKit
import RxSwift
import LGComponents

enum NotificationSettingsType {
    case searchAlerts
    case push
    case mail
    
    var title: String {
        switch self {
        case .searchAlerts:
            return R.Strings.settingsNotificationsSearchAlerts
        case .push:
            return R.Strings.settingsNotificationsPushNotifications
        case .mail:
            return R.Strings.settingsNotificationsEmail
        }
    }
    
    var cellHeight: CGFloat {
        return 50
    }
    
    var isPush: Bool {
        switch self {
        case .push:
            return true
        case .searchAlerts, .mail:
            return false
        }
    }
}

final class NotificationSettingsViewModel: BaseViewModel {
    
    weak var navigator: NotificationSettingsNavigator?
    weak var delegate: BaseViewModelDelegate?
    
    private let settings: [NotificationSettingsType] = [.push, .mail, .searchAlerts]
    
    private let myUserRepository: MyUserRepository
    private let notificationsManager: NotificationsManager
    private let pushPermissionManager: PushPermissionsManager
    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  pushPermissionManager: LGPushPermissionsManager.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance)
    }
    
    init(myUserRepository: MyUserRepository,
         notificationsManager: NotificationsManager,
         pushPermissionManager: PushPermissionsManager,
         tracker: Tracker,
         featureFlags: FeatureFlaggeable) {
        self.myUserRepository = myUserRepository
        self.notificationsManager = notificationsManager
        self.pushPermissionManager = pushPermissionManager
        self.tracker = tracker
        self.featureFlags = featureFlags
        super.init()
    }
    
    
    // MARK: - TableView configuration
    
    var settingsCount: Int {
        return settings.count
    }

    func settingAtIndex(_ index: Int) -> NotificationSettingsType? {
        return settings[safeAt: index]
    }
    
    func settingSelectedAtIndex(_ index: Int) {
        guard let setting = settingAtIndex(index) else { return }
        switch setting {
        case .searchAlerts:
            navigator?.openSearchAlertsList()
        case .push:
            navigator?.openNotificationSettingsList(notificationSettingsType: .push)
        case .mail:
            navigator?.openNotificationSettingsList(notificationSettingsType: .mail)
        }
    }
}
