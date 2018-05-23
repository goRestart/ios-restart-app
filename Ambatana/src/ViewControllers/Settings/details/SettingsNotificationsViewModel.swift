import LGCoreKit
import RxSwift
import LGComponents

enum NotificationsSetting {
    case marketingNotifications(switchValue: Variable<Bool>, changeClosure: ((Bool) -> Void))
    case searchAlerts
    
    var title: String {
        switch self {
        case .marketingNotifications:
            return R.Strings.settingsMarketingNotificationsSwitch
        case .searchAlerts:
            return R.Strings.settingsNotificationsSearchAlerts
        }
    }
    
    var cellHeight: CGFloat {
        return 50
    }
}

final class SettingsNotificationsViewModel: BaseViewModel {
    
    weak var navigator: SettingsNotificationsNavigator?
    weak var delegate: BaseViewModelDelegate?
    
    let settings = Variable<[NotificationsSetting]>([])
    let switchMarketingNotificationValue = Variable<Bool>(true)
    
    private let myUserRepository: MyUserRepository
    private let notificationsManager: NotificationsManager
    private let pushPermissionManager: PushPermissionsManager
    private let tracker: Tracker
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  pushPermissionManager: LGPushPermissionsManager.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    init(myUserRepository: MyUserRepository,
         notificationsManager: NotificationsManager,
         pushPermissionManager: PushPermissionsManager,
         tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.notificationsManager = notificationsManager
        self.pushPermissionManager = pushPermissionManager
        self.tracker = tracker
        super.init()
        
        
        setupRx()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        switchMarketingNotificationValue.value = pushPermissionManager.pushNotificationActive && notificationsManager.marketingNotifications.value
    }
    
    private func setupRx() {
        myUserRepository.rx_myUser.bind { [weak self] _ in
            self?.makeSettings()
            }.disposed(by: disposeBag)
    }
    
    private func makeSettings() {
        var notificationsSettings = [NotificationsSetting]()
        notificationsSettings.append(.marketingNotifications(switchValue: switchMarketingNotificationValue,
                                                       changeClosure: { [weak self] enabled in self?.checkMarketingNotifications(enabled) } ))
        notificationsSettings.append(.searchAlerts)
        settings.value = notificationsSettings
    }
    
    private func checkMarketingNotifications(_ enabled: Bool) {
        if enabled {
            showPrePermissionsIfNeeded()
        } else {
            showDeactivateConfirmation()
        }
    }
    
    
    // MARK: - TableView configuration
    
    var settingsCount: Int {
        return settings.value.count
    }

    func settingAtIndex(_ index: Int) -> NotificationsSetting? {
        guard 0..<settings.value.count ~= index else { return nil }
        return settings.value[index]
    }
    
    func settingSelectedAtIndex(_ index: Int) {
        guard let setting = settingAtIndex(index) else { return }
        switch setting {
        case .marketingNotifications:
            break
        case .searchAlerts:
            navigator?.openSearchAlertsList()
        }
    }
    
    
    // MARK: - Marketing notifications
    
    private func setMarketingNotification(enabled: Bool) {
        notificationsManager.marketingNotifications.value = enabled
        let event = TrackerEvent.marketingPushNotifications(myUserRepository.myUser?.objectId, enabled: enabled)
        tracker.trackEvent(event)
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
}
