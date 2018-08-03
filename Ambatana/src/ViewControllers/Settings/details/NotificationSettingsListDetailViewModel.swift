import LGCoreKit
import LGComponents
import RxSwift

final class NotificationSettingsListDetailViewModel: BaseViewModel {
    
    weak var navigator: NotificationSettingsNavigator?
    weak var delegate: BaseViewModelDelegate?
    
    private let tracker: Tracker
    private let notificationSettingsRepository: NotificationSettingsRepository
    
    let settings = Variable<[NotificationSettingCellType]>([])
    let notificationSetting: NotificationSetting
    var groupSettings: [NotificationGroupSetting]
    
    
    // MARK: - Lifecycle
    
    convenience init(notificationSetting: NotificationSetting,
                     notificationSettingsRepository: NotificationSettingsRepository) {
        self.init(notificationSetting: notificationSetting,
                  notificationSettingsRepository: notificationSettingsRepository,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    required init(notificationSetting: NotificationSetting,
                  notificationSettingsRepository: NotificationSettingsRepository,
                  tracker: Tracker) {
        self.notificationSetting = notificationSetting
        self.tracker = tracker
        self.groupSettings = notificationSetting.groupSettings
        self.notificationSettingsRepository = notificationSettingsRepository
        super.init()
        
        makeSettings()
    }
    
    private func makeSettings() {
        var notificationSettingCells = [NotificationSettingCellType]()
        
        for groupSetting in groupSettings {
            notificationSettingCells
                .append(.switcher(title: groupSetting.name,
                                     description: groupSetting.description,
                                     isEnabled: Variable<Bool>(groupSetting.isEnabled),
                                     switchAction: { [weak self] isEnabled in
                self?.enableGroupSetting(groupSetting, isEnabled: isEnabled)
            }))
        }
        
        settings.value = notificationSettingCells
    }
    
    func enableGroupSetting(_ groupSetting: NotificationGroupSetting, isEnabled: Bool) {
        if !groupSetting.isEnabled {
            enableNotificationGroupSetting(groupSetting)
        } else {
            disableNotificationGroupSetting(groupSetting)
        }
    }
    
    private func enableNotificationGroupSetting(_ notificationGroupSetting: NotificationGroupSetting) {
        guard let groupId = notificationSetting.objectId,
            let settingId = notificationGroupSetting.objectId else { return }
        notificationSettingsRepository.enable(groupId: groupId,
                                              settingId: settingId) { [weak self] result in
            if let _ = result.value {
                self?.updateNotificationGroupSetting(notificationGroupSetting, isEnabled: true)
            } else {
                self?.delegate?.vmShowAutoFadingMessage(R.Strings.commonErrorGenericBody) { [weak self] in
                    self?.updateNotificationGroupSetting(notificationGroupSetting, isEnabled: false)
                }
            }
        }
    }
    
    private func disableNotificationGroupSetting(_ notificationGroupSetting: NotificationGroupSetting) {
        guard let groupId = notificationSetting.objectId,
            let settingId = notificationGroupSetting.objectId else { return }
        notificationSettingsRepository.disable(groupId: groupId,
                                               settingId: settingId) { [weak self] result in
            if let _ = result.value {
                self?.updateNotificationGroupSetting(notificationGroupSetting, isEnabled: false)
            } else {
                self?.delegate?.vmShowAutoFadingMessage(R.Strings.commonErrorGenericBody) { [weak self] in
                    self?.updateNotificationGroupSetting(notificationGroupSetting, isEnabled: true)
                }
            }
        }
    }
    
    private func updateNotificationGroupSetting(_ groupSetting: NotificationGroupSetting, isEnabled: Bool)  {
        let newNotificationGroupSetting = groupSetting.updating(isEnabled: isEnabled)
        if let index = groupSettings.index(where: { $0.objectId == groupSetting.objectId }) {
            groupSettings[index] = newNotificationGroupSetting
        }
        makeSettings()
    }
}
