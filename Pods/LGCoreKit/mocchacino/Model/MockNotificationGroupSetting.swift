public struct MockNotificationGroupSetting: NotificationGroupSetting {
    public var objectId: String?
    public var name: String
    public var description: String?
    public var isEnabled: Bool
    
    public init(objectId: String?, name: String, description: String?, isEnabled: Bool) {
        self.objectId = objectId
        self.name = name
        self.description = description
        self.isEnabled = isEnabled
    }
}
