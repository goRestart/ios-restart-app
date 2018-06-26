import Result

final class LGNotificationSettingsPusherRepository: NotificationSettingsPusherRepository {
    
    private let dataSource: NotificationSettingsPusherDataSource
    
    
    // MARK: - Lifecycle
    
    init(dataSource: NotificationSettingsPusherDataSource) {
        self.dataSource = dataSource
    }
    
    
    // MARK: - Public methods
    
    func index(completion: NotificationSettingsIndexCompletion?) {
        dataSource.index { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    func enable(groupId: String, settingId: String, completion: NotificationSettingsEmptyCompletion?) {
        dataSource.enable(groupId: groupId, settingId: settingId) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    func disable(groupId: String, settingId: String, completion: NotificationSettingsEmptyCompletion?) {
        dataSource.disable(groupId: groupId, settingId: settingId) { result in
            handleApiResult(result, completion: completion)
        }
    }
}
