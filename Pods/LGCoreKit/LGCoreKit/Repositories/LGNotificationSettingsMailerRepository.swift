import Result

final class LGNotificationSettingsMailerRepository: NotificationSettingsMailerRepository {
    
    let dataSource: NotificationSettingsMailerDataSource
    
    
    // MARK: - Lifecycle
    
    init(dataSource: NotificationSettingsMailerDataSource) {
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

