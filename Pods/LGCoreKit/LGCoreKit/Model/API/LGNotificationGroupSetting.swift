public struct LGNotificationGroupSetting: NotificationGroupSetting, Decodable {
    
    public let objectId: String?
    public let name: String
    public let description: String?
    public let isEnabled: Bool
    
    public init(objectId: String?, name: String, description: String?, isEnabled: Bool) {
        self.objectId = objectId
        self.name = name
        self.description = description
        self.isEnabled = isEnabled
    }
    
    
    // MARK: Decodable
    
    /*
     {
     "setting_id": "chat_messages",
     "setting_name": "Chat Messages",
     "setting_description": "[NULLABLE] - Some description, note that some settings might not have description, leaving this field as null.",
     "is_enabled": true
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .id)
        name = try keyedContainer.decode(String.self, forKey: .name)
        description = try keyedContainer.decodeIfPresent(String.self, forKey: .description)
        isEnabled = try keyedContainer.decode(Bool.self, forKey: .isEnabled)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "setting_id"
        case name = "setting_name"
        case description = "setting_description"
        case isEnabled = "is_enabled"
    }
}
