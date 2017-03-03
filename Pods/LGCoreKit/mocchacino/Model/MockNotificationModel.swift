public struct MockNotificationModel: NotificationModel {
    public var objectId: String?
    public var createdAt: Date
    public var isRead: Bool
    public var type: NotificationType
}
