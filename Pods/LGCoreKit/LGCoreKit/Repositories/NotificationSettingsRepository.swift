import Result

public typealias NotificationSettingsIndexResult = Result<[NotificationSetting], RepositoryError>
public typealias NotificationSettingsIndexCompletion = (NotificationSettingsIndexResult) -> Void

public typealias NotificationSettingsEmptyResult = Result<Void, RepositoryError>
public typealias NotificationSettingsEmptyCompletion = (NotificationSettingsEmptyResult) -> Void

public protocol NotificationSettingsRepository {
    func index(completion: NotificationSettingsIndexCompletion?)
    func enable(groupId: String, settingId: String, completion: NotificationSettingsEmptyCompletion?)
    func disable(groupId: String, settingId: String, completion: NotificationSettingsEmptyCompletion?)
}

public protocol NotificationSettingsPusherRepository: NotificationSettingsRepository {}
public protocol NotificationSettingsMailerRepository: NotificationSettingsRepository {}
