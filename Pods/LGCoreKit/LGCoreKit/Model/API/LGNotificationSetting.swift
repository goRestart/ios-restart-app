public struct LGNotificationSetting: NotificationSetting, Decodable {
    
    public let objectId: String?
    public let name: String
    public let groupSettings: [NotificationGroupSetting]
    
    
    // MARK: Decodable
    
    /*
     {
     "group_id": "messages",
     "group_name": "Messages",
     "group_settings": [{
     "setting_id": "chat_messages",
     "setting_name": "Chat Messages",
     "setting_description": "[NULLABLE] - Some description, note that some settings might not have description, leaving this field as null.",
     "is_enabled": true
     }]
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .id)
        name = try keyedContainer.decode(String.self, forKey: .name)
        if let groupSettings = try keyedContainer.decodeIfPresent(FailableDecodableArray<LGNotificationGroupSetting>.self,
                                                                  forKey: .groupSettings) {
            self.groupSettings = groupSettings.validElements
        } else {
            self.groupSettings = []
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "group_id"
        case name = "group_name"
        case groupSettings = "group_settings"
    }
}
