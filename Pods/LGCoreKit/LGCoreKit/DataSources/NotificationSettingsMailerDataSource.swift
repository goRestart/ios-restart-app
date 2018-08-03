import Result

typealias NotificationSettingsMailerEmptyDataSourceResult = Result<Void, ApiError>
typealias NotificationSettingsMailerEmptyDataSourceCompletion = (NotificationSettingsMailerEmptyDataSourceResult) -> Void

typealias NotificationSettingsMailerIndexDataSourceResult = Result<[NotificationSetting], ApiError>
typealias NotificationSettingsMailerIndexDataSourceCompletion = (NotificationSettingsMailerIndexDataSourceResult) -> Void

protocol NotificationSettingsMailerDataSource {
    func index(completion: NotificationSettingsMailerIndexDataSourceCompletion?)
    func enable(groupId: String, settingId: String, completion: NotificationSettingsMailerEmptyDataSourceCompletion?)
    func disable(groupId: String, settingId: String, completion: NotificationSettingsMailerEmptyDataSourceCompletion?)
}

