import LGComponents
import LGCoreKit
import RxSwift

final class NotificationSettingsCompleteListViewModel: BaseViewModel {
    
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
    
    var switchMarketingNotificationValue: Bool
    var notificationSettingsCells = Variable<[NotificationSettingCellType]>([])
    private var notificationSettings: [NotificationSetting] = []
    private var groupSettings: [NotificationGroupSetting] = []
    var dataState = Variable<DataState>(.initial)
    
    
    // MARK: - Lifecycle
    
    static func makeMailerNotificationSettingsListViewModel() -> NotificationSettingsCompleteListViewModel {
        return NotificationSettingsCompleteListViewModel(notificationSettingsType: .mail,
                                                         notificationSettingsRepository: Core.notificationSettingsMailerRepository)
    }
    
    static func makePusherNotificationSettingsListViewModel() -> NotificationSettingsCompleteListViewModel {
        return NotificationSettingsCompleteListViewModel(notificationSettingsType: .push,
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
        self.switchMarketingNotificationValue = pushPermissionManager.pushNotificationActive &&
            notificationsManager.marketingNotifications.value
        super.init()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        retrieveNotificationSettings()
    }
    
    
    // MARK: - Requests
    
    private func retrieveNotificationSettings() {
        dataState.value = .refreshing
        notificationSettingsRepository.index { [weak self] result in
            if let notificationSettings = result.value {
                self?.notificationSettings = notificationSettings
                self?.makeGroupSettings()
                self?.makeNotificationSettingCells()
                self?.dataState.value = .loaded
            } else {
                self?.dataState.value = .error(retryAction: { [weak self] in
                    self?.retrieveNotificationSettings()
                })
            }
        }
    }
    
    private func makeGroupSettings() {
        groupSettings = notificationSettings.reduce([], { $0 + $1.groupSettings })
    }
    
    
    // MARK: - Cell factory
    
    private func makeNotificationSettingCells() {
        var cells = [NotificationSettingCellType]()
        for groupSetting in groupSettings {
            cells.append(.switcher(title: groupSetting.name,
                                   description: groupSetting.description,
                                   isEnabled: Variable<Bool>(groupSetting.isEnabled),
                                   switchAction: { [weak self] isEnabled in
                                    self?.enableGroupSetting(groupSetting,
                                                             isEnabled: isEnabled)
            }))
        }
        if notificationSettingsType.isPush {
            cells.append(.marketing(switchValue: Variable<Bool>(switchMarketingNotificationValue),
                                    changeClosure: { [weak self] enabled in
                                        self?.checkMarketingNotifications(enabled)
                                        
            } ))
        }
        notificationSettingsCells.value = cells
    }
    
    private func getNotificationSettingIdFromGroupSetting(_ groupSetting: NotificationGroupSetting) -> String? {
        guard let index = notificationSettings.index(where: {
            $0.groupSettings.contains(where: {
                $0.objectId == groupSetting.objectId
            })
        }) else { return nil }
        guard let notificationSettingId = notificationSettings[index].objectId else { return nil }
        return notificationSettingId
    }
    
    
    // MARK: - Notification settings updates
    
    func enableGroupSetting(_ groupSetting: NotificationGroupSetting, isEnabled: Bool) {
        if isEnabled {
            enableNotificationGroupSetting(groupSetting)
        } else {
            disableNotificationGroupSetting(groupSetting)
        }
    }
    
    private func enableNotificationGroupSetting(_ notificationGroupSetting: NotificationGroupSetting) {
        guard let groupId = getNotificationSettingIdFromGroupSetting(notificationGroupSetting),
            let settingId = notificationGroupSetting.objectId else { return }
        notificationSettingsRepository.enable(groupId: groupId,
                                              settingId: settingId) { [weak self] result in
                                                if let _ = result.value {
                                                    self?.updateNotificationGroupSetting(notificationGroupSetting,
                                                                                         isEnabled: true)
                                                } else {
                                                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.commonErrorGenericBody) { [weak self] in
                                                        self?.updateNotificationGroupSetting(notificationGroupSetting,
                                                                                             isEnabled: false)
                                                    }
                                                }
        }
    }
    
    private func disableNotificationGroupSetting(_ notificationGroupSetting: NotificationGroupSetting) {
        guard let groupId = getNotificationSettingIdFromGroupSetting(notificationGroupSetting),
            let settingId = notificationGroupSetting.objectId else { return }
        notificationSettingsRepository.disable(groupId: groupId,
                                               settingId: settingId) { [weak self] result in
                                                if let _ = result.value {
                                                    self?.updateNotificationGroupSetting(notificationGroupSetting,
                                                                                         isEnabled: false)
                                                } else {
                                                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.commonErrorGenericBody) { [weak self] in
                                                        self?.updateNotificationGroupSetting(notificationGroupSetting,
                                                                                             isEnabled: true)
                                                    }
                                                }
        }
    }
    
    private func updateNotificationGroupSetting(_ groupSetting: NotificationGroupSetting, isEnabled: Bool)  {
        let newNotificationGroupSetting = groupSetting.updating(isEnabled: isEnabled)
        if let index = groupSettings.index(where: { $0.objectId == groupSetting.objectId }) {
            groupSettings[index] = newNotificationGroupSetting
        }
        makeNotificationSettingCells()
    }
    
    
    // MARK: Marketing notifications
    
    private func setMarketingNotification(enabled: Bool) {
        notificationsManager.marketingNotifications.value = enabled
        let event = TrackerEvent.marketingPushNotifications(myUserRepository.myUser?.objectId, enabled: enabled)
        tracker.trackEvent(event)
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
        switchMarketingNotificationValue = enabled
    }
}
