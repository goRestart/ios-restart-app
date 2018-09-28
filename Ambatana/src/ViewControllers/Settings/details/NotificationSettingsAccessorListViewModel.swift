import LGComponents
import LGCoreKit
import RxSwift

fileprivate extension Array where Element == NotificationSetting {
    func getTrackingParams() -> [String: Bool] {
        return self.flatMap({ $0.groupSettings }).reduce([:]) { (dict, keyValue) -> [String: Bool] in
            var newDict = dict
            if let objectId = keyValue.objectId {
                newDict[objectId] = keyValue.isEnabled
            }
            return newDict
        }
    }
}


final class NotificationSettingsAccessorListViewModel: BaseViewModel {
    
    enum DataState {
        case initial
        case loaded
        case refreshing
        case error(retryAction: () -> Void)
        
        var placeholderText: String? {
            switch self {
            case .error:
                return R.Strings.settingsNotificationsErrorMessage
            case .initial, .loaded, .refreshing:
                return nil
            }
        }
        
        var retryText: String? {
            switch self {
            case .error:
                return R.Strings.settingsNotificationsErrorButton
            case .initial, .loaded, .refreshing:
                return nil
            }
        }
        
        var retryAction: (() -> Void)? {
            switch self {
            case .error(let retryAction):
                return retryAction
            case .initial, .loaded, .refreshing:
                return nil
            }
        }
    }
    
    weak var navigator: NotificationSettingsNavigator?
    weak var delegate: BaseViewModelDelegate?
    
    let notificationSettingsType: NotificationSettingsType
    private let notificationSettingsRepository: NotificationSettingsRepository
    private let myUserRepository: MyUserRepository
    private let notificationsManager: NotificationsManager
    private let pushPermissionManager: PushPermissionsManager
    private let tracker: Tracker
    
    var switchMarketingNotificationValue = Variable<Bool>(true)
    var notificationSettingsCells = Variable<[NotificationSettingCellType]>([])
    var notificationSettings = Variable<[NotificationSetting]>([])
    var dataState = Variable<DataState>(.initial)
    private var trackingParams: [String: Bool] {
        return notificationSettings.value.getTrackingParams()
    }
    
    
    // MARK: - Lifecycle
    
    static func makeMailerNotificationSettingsListViewModel() -> NotificationSettingsAccessorListViewModel {
        return NotificationSettingsAccessorListViewModel(notificationSettingsType: .mail,
                                                         notificationSettingsRepository: Core.notificationSettingsMailerRepository)
    }
    
    static func makePusherNotificationSettingsListViewModel() -> NotificationSettingsAccessorListViewModel {
        return NotificationSettingsAccessorListViewModel(notificationSettingsType: .push,
                                                         notificationSettingsRepository: Core.notificationSettingsPusherRepository)
    }
    
    convenience init(notificationSettingsType: NotificationSettingsType,
                     notificationSettingsRepository: NotificationSettingsRepository) {
        self.init(notificationSettingsType: notificationSettingsType,
                  notificationSettingsRepository: notificationSettingsRepository,
                  myUserRepository: Core.myUserRepository,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  pushPermissionManager: LGPushPermissionsManager.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    required init(notificationSettingsType: NotificationSettingsType,
         notificationSettingsRepository: NotificationSettingsRepository,
         myUserRepository: MyUserRepository,
         notificationsManager: NotificationsManager,
         pushPermissionManager: PushPermissionsManager,
         tracker: Tracker) {
        self.notificationSettingsType = notificationSettingsType
        self.notificationSettingsRepository = notificationSettingsRepository
        self.myUserRepository = myUserRepository
        self.notificationsManager = notificationsManager
        self.pushPermissionManager = pushPermissionManager
        self.tracker = tracker
        super.init()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        retrieveNotificationSettings()
        switchMarketingNotificationValue.value = pushPermissionManager.pushNotificationActive && notificationsManager.marketingNotifications.value
        if firstTime {
            trackNotificationsEditStart()
        }
    }
    
    override func backButtonPressed() -> Bool {
        trackEnablingSettings()
        return false
    }
    
    
    // MARK: - Requests
    
    private func retrieveNotificationSettings() {
        dataState.value = .refreshing
        notificationSettingsRepository.index { [weak self] result in
            if let notificationSettings = result.value {
                self?.notificationSettings.value = notificationSettings
                self?.makeNotificationSettingCells(notificationSettings: notificationSettings)
                self?.dataState.value = .loaded
            } else {
                self?.dataState.value = .error(retryAction: { [weak self] in
                    self?.retrieveNotificationSettings()
                })
            }
        }
    }
    
    
    // MARK: - Cell factory
    
    private func makeNotificationSettingCells(notificationSettings: [NotificationSetting]) {
        var cells = [NotificationSettingCellType]()
        for notificationSetting in notificationSettings {
            cells.append(.accessor(title: notificationSetting.name))
        }
        if notificationSettingsType.isPush {
            cells.append(.marketing(switchValue: switchMarketingNotificationValue,
                                    changeClosure: { [weak self] enabled in
                                        self?.checkMarketingNotifications(enabled)
                                        
            } ))
        }
        notificationSettingsCells.value = cells
    }
    
    
    // MARK: - Routing
    
    func openNotificationSettingsListDetail(notificationSetting: NotificationSetting) {
        navigator?.openNotificationSettingsListDetail(notificationSetting: notificationSetting,
        notificationSettingsRepository: notificationSettingsRepository)
    }
    
    
    // MARK: - Marketing notifications
    
    private func setMarketingNotification(enabled: Bool) {
        notificationsManager.marketingNotifications.value = enabled
    }
    
    private func checkMarketingNotifications(_ enabled: Bool) {
        if enabled {
            showPrePermissionsIfNeeded()
        } else {
            showDeactivateConfirmation()
        }
    }
    
    private func showPrePermissionsIfNeeded() {
        guard !pushPermissionManager.pushNotificationActive else {
            setMarketingNotification(enabled: true)
            return
        }
        let cancelAction = UIAction(
            interface: .button(R.Strings.settingsMarketingNotificationsAlertCancel, .secondary(fontSize: .medium, withBorder: true)),
            action: { [weak self] in
                self?.forceMarketingNotifications(enabled: false)
        })
        let activateAction = UIAction(interface: .button(R.Strings.settingsMarketingNotificationsAlertActivate,
                                                         .primary(fontSize: .medium)),
                                      action: { [weak self] in
                                        self?.setMarketingNotification(enabled: true)
                                        self?.pushPermissionManager.showPushPermissionsAlert(prePermissionType: .profile)
        })
        
        delegate?.vmShowAlertWithTitle(nil, text: R.Strings.settingsGeneralNotificationsAlertMessage,
                                       alertType: .plainAlertOld, actions: [cancelAction, activateAction])
    }
    
    private func showDeactivateConfirmation() {
        let cancelAction = UIAction(
            interface: .button(R.Strings.settingsMarketingNotificationsAlertCancel, .secondary(fontSize: .medium, withBorder: true)),
            action: { [weak self] in
                self?.forceMarketingNotifications(enabled: true)
        })
        let  deactivateAction = UIAction(
            interface: .button(R.Strings.settingsMarketingNotificationsAlertDeactivate, .secondary(fontSize: .medium, withBorder: true)),
            action: { [weak self] in
                self?.setMarketingNotification(enabled: false)
        })
        delegate?.vmShowAlertWithTitle(nil, text: R.Strings.settingsMarketingNotificationsAlertMessage,
                                       alertType: .plainAlertOld, actions: [cancelAction, deactivateAction], dismissAction: cancelAction.action)
    }
    
    private func forceMarketingNotifications(enabled: Bool) {
        notificationsManager.marketingNotifications.value = enabled
        switchMarketingNotificationValue.value = enabled
    }
    
    
    // MARK: - Tracking
    
    private func trackNotificationsEditStart() {
        let event = TrackerEvent.notificationsEditStart()
        tracker.trackEvent(event)
    }
    
    private func trackEnablingSettings() {
        switch notificationSettingsType {
        case .push:
            trackPushNotificationsStatus()
        case .mail:
            trackMailNotificationsStatus()
        case .searchAlerts:
            break
        }
    }
    
    private func trackPushNotificationsStatus() {
        let event = TrackerEvent.pushNotificationsEditStart(dynamicParameters: trackingParams,
                                                            marketingNoticationsEnabled: switchMarketingNotificationValue.value)
        tracker.trackEvent(event)
    }
    
    private func trackMailNotificationsStatus() {
        let event = TrackerEvent.mailNotificationsEditStart(dynamicParameters: trackingParams)
        tracker.trackEvent(event)
    }
}
