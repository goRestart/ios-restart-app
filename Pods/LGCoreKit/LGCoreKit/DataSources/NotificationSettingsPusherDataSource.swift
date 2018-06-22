import Result

typealias NotificationSettingsEmptyDataSourceResult = Result<Void, ApiError>
typealias NotificationSettingsEmptyDataSourceCompletion = (NotificationSettingsEmptyDataSourceResult) -> Void

typealias NotificationSettingsIndexDataSourceResult = Result<[NotificationSetting], ApiError>
typealias NotificationSettingsIndexDataSourceCompletion = (NotificationSettingsIndexDataSourceResult) -> Void

protocol NotificationSettingsPusherDataSource {
    func index(completion: NotificationSettingsIndexDataSourceCompletion?)
    func enable(groupId: String, settingId: String, completion: NotificationSettingsEmptyDataSourceCompletion?)
    func disable(groupId: String, settingId: String, completion: NotificationSettingsEmptyDataSourceCompletion?)
}

