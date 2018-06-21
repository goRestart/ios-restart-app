final class NotificationSettingsMailerApiDataSource: NotificationSettingsMailerDataSource {
    
    let apiClient: ApiClient
    
    struct Keys {
        static let data = "data"
        static let notificationSettings = "notification_settings"
    }
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    // MARK: - Actions
    
    func index(completion: NotificationSettingsMailerIndexDataSourceCompletion?) {
        let request = NotificationSettingsMailerRouter.index
        apiClient.request(request, decoder: NotificationSettingsMailerApiDataSource.decoderArray, completion: completion)
    }
    
    func enable(groupId: String, settingId: String, completion: NotificationSettingsMailerEmptyDataSourceCompletion?) {
        let request = NotificationSettingsMailerRouter.enable(groupId: groupId, settingId: settingId)
        apiClient.request(request, completion: completion)
    }
    
    func disable(groupId: String, settingId: String, completion: NotificationSettingsMailerEmptyDataSourceCompletion?) {
        let request = NotificationSettingsMailerRouter.disable(groupId: groupId, settingId: settingId)
        apiClient.request(request, completion: completion)
    }
    
    
    // MARK: - Decoders
    
    private static func decoderArray(_ object: Any) -> [NotificationSetting]? {
        guard let dataDict = object as? [String : Any] else { return nil }
        guard let notificationSettingsDict = dataDict[Keys.data] as? [String : [[String : Any]]] else { return nil }
        guard let notificationSettingsArray = notificationSettingsDict[Keys.notificationSettings]
            else { return nil }
        guard let notificationSettingsData = try? JSONSerialization.data(withJSONObject: notificationSettingsArray,
                                                                         options: .prettyPrinted) else { return nil }
        do {
            let notificationSettings = try JSONDecoder().decode(FailableDecodableArray<LGNotificationSetting>.self,
                                                                from: notificationSettingsData)
            return notificationSettings.validElements
        } catch {
            logAndReportParseError(object: object, entity: .notificationSettings,
                                   comment: "could not parse [NotificationSetting]")
        }
        return nil
    }
}
