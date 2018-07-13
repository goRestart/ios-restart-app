import LGComponents
import LGCoreKit
import RxSwift

fileprivate extension Array where Element == NotificationGroupSetting {
    func getTrackingParams() -> [String: Bool] {
        return self.reduce([:]) { (dict, keyValue) -> [String: Bool] in
            var newDict = dict
            if let objectId = keyValue.objectId {
                newDict[objectId] = keyValue.isEnabled
            }
            return newDict
        }
    }
}

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
    
    struct Section {
        let title: String
        let settings: [NotificationSettingCellType]
    }

    struct NotificationSettingData {
        var objectId: String?
        var name: String
        var groupSettings: [NotificationGroupSetting]
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
    private var notificationSettingsData: [NotificationSettingData] = []
    private var groupSettings: [NotificationGroupSetting] = []
    var dataState = Variable<DataState>(.initial)
    var sections = Variable<[Section]>([])
    private var trackingParams: [String: Bool] {
        return groupSettings.getTrackingParams()
    }
    
    
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
        super.init()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        retrieveNotificationSettings()
        switchMarketingNotificationValue.value = pushPermissionManager.pushNotificationActive &&
            notificationsManager.marketingNotifications.value
        if firstTime {
            trackNotificationsEditStart()
        }
    }

    override func didBecomeInactive() {
        super.didBecomeInactive()
        trackEnablingSettings()
    }
    
    
    // MARK: - Requests
    
    private func retrieveNotificationSettings() {
        dataState.value = .refreshing
        notificationSettingsRepository.index { [weak self] result in
            if let notificationSettings = result.value {
                self?.makeNotificationSettingsData(notificationSettings: notificationSettings)
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
    
    private func makeNotificationSettingsData(notificationSettings: [NotificationSetting]) {
        var newNotificationSettingsData: [NotificationSettingData] = []
        for notificationSetting in notificationSettings {
            newNotificationSettingsData.append(NotificationSettingData(objectId: notificationSetting.objectId,
                                                                       name: notificationSetting.name,
                                                                       groupSettings: notificationSetting.groupSettings))
        }
        notificationSettingsData = newNotificationSettingsData
    }
    
    private func makeGroupSettings() {
        groupSettings = notificationSettingsData.reduce([], { $0 + $1.groupSettings })
    }
    
    
    // MARK: - Cell factory
    
    private func makeNotificationSettingCells() {
        var newSections = [Section]()
        for (index, notificationSetting) in notificationSettingsData.enumerated() {
            var groupSettingCells = [NotificationSettingCellType]()
            for groupSetting in notificationSetting.groupSettings {
                groupSettingCells.append(.switcher(title: groupSetting.name,
                                                   description: groupSetting.description,
                                                   isEnabled: Variable<Bool>(groupSetting.isEnabled),
                                                   switchAction: { [weak self] isEnabled in
                                                    self?.enableGroupSetting(groupSetting,
                                                                             notificationSetting: notificationSetting,
                                                                             isEnabled: isEnabled)
                }))
            }
            if notificationSettingsType.isPush && index == notificationSettingsData.count-1 {
                groupSettingCells.append(.marketing(switchValue: switchMarketingNotificationValue,
                                                    changeClosure: { [weak self] enabled in
                                                        self?.checkMarketingNotifications(enabled)
                }))
            }
            newSections.append(Section(title: notificationSetting.name, settings: groupSettingCells))
        }
        sections.value = newSections
    }
    
    func cellDataFor(section: Int, row: Int) -> NotificationSettingCellType {
        return sections.value[section].settings[row]
    }
    
    
    // MARK: - Notification settings updates
    
    func enableGroupSetting(_ groupSetting: NotificationGroupSetting,
                            notificationSetting: NotificationSettingData,
                            isEnabled: Bool) {
        if isEnabled {
            enableNotificationGroupSetting(groupSetting, notificationSetting: notificationSetting)
        } else {
            disableNotificationGroupSetting(groupSetting, notificationSetting: notificationSetting)
        }
    }
    
    private func enableNotificationGroupSetting(_ notificationGroupSetting: NotificationGroupSetting,
                                                notificationSetting: NotificationSettingData) {
        guard let groupId = notificationSetting.objectId,
            let settingId = notificationGroupSetting.objectId else { return }
        notificationSettingsRepository.enable(groupId: groupId,
                                              settingId: settingId) { [weak self] result in
                                                if let _ = result.value {
                                                    self?.updateNotificationGroupSetting(notificationGroupSetting,
                                                                                         notificationSetting: notificationSetting,
                                                                                         isEnabled: true)
                                                } else {
                                                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.commonErrorGenericBody) { [weak self] in
                                                        self?.updateNotificationGroupSetting(notificationGroupSetting,
                                                                                             notificationSetting: notificationSetting,
                                                                                             isEnabled: false)
                                                    }
                                                }
        }
    }
    
    private func disableNotificationGroupSetting(_ notificationGroupSetting: NotificationGroupSetting,
                                                 notificationSetting: NotificationSettingData) {
        guard let groupId = notificationSetting.objectId,
            let settingId = notificationGroupSetting.objectId else { return }
        notificationSettingsRepository.disable(groupId: groupId,
                                               settingId: settingId) { [weak self] result in
                                                if let _ = result.value {
                                                    self?.updateNotificationGroupSetting(notificationGroupSetting,
                                                                                         notificationSetting: notificationSetting,
                                                                                         isEnabled: false)
                                                } else {
                                                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.commonErrorGenericBody) { [weak self] in
                                                        self?.updateNotificationGroupSetting(notificationGroupSetting,
                                                                                             notificationSetting: notificationSetting,
                                                                                             isEnabled: true)
                                                    }
                                                }
        }
    }
    
    private func updateNotificationGroupSetting(_ groupSetting: NotificationGroupSetting,
                                                notificationSetting: NotificationSettingData,
                                                isEnabled: Bool)  {
        let newNotificationGroupSetting = groupSetting.updating(isEnabled: isEnabled)
        if let indexNotificationSetting = notificationSettingsData.index(where: {$0.objectId == notificationSetting.objectId}) {
            if let indexGroupSetting = notificationSettingsData[indexNotificationSetting].groupSettings.index(where: { $0.objectId == groupSetting.objectId }) {
                notificationSettingsData[indexNotificationSetting].groupSettings[indexGroupSetting] = newNotificationGroupSetting
            }
        }
        makeGroupSettings()
        makeNotificationSettingCells()
    }
    
    
    // MARK: - Marketing notifications
    
    private func setMarketingNotifications(enabled: Bool) {
        notificationsManager.marketingNotifications.value = enabled
        switchMarketingNotificationValue.value = enabled
        makeGroupSettings()
        makeNotificationSettingCells()
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
            setMarketingNotifications(enabled: true)
            return
        }
        let cancelAction = UIAction(
            interface: .button(R.Strings.settingsMarketingNotificationsAlertCancel, .secondary(fontSize: .medium, withBorder: true)),
            action: { [weak self] in
                self?.setMarketingNotifications(enabled: false)
        })
        let activateAction = UIAction(interface: .button(R.Strings.settingsMarketingNotificationsAlertActivate,
                                                         .primary(fontSize: .medium)),
                                      action: { [weak self] in
                                        self?.setMarketingNotifications(enabled: true)
                                        self?.pushPermissionManager.showPushPermissionsAlert(prePermissionType: .profile)
        })
        
        delegate?.vmShowAlertWithTitle(nil, text: R.Strings.settingsGeneralNotificationsAlertMessage,
                                       alertType: .plainAlertOld, actions: [cancelAction, activateAction])
    }
    
    private func showDeactivateConfirmation() {
        let cancelAction = UIAction(
            interface: .button(R.Strings.settingsMarketingNotificationsAlertCancel, .secondary(fontSize: .medium, withBorder: true)),
            action: { [weak self] in
                self?.setMarketingNotifications(enabled: true)
        })
        let  deactivateAction = UIAction(
            interface: .button(R.Strings.settingsMarketingNotificationsAlertDeactivate, .secondary(fontSize: .medium, withBorder: true)),
            action: { [weak self] in
                self?.setMarketingNotifications(enabled: false)
        })
        delegate?.vmShowAlertWithTitle(nil, text: R.Strings.settingsMarketingNotificationsAlertMessage,
                                       alertType: .plainAlertOld, actions: [cancelAction, deactivateAction], dismissAction: cancelAction.action)
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
        case .marketing, .searchAlerts:
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
