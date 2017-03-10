public struct MockNotificationModular: NotificationModular {
    public var text: NotificationTextModule
    public var callToActions: [NotificationCTAModule]
    public var basicImage: NotificationImageModule?
    public var iconImage: NotificationImageModule?
    public var heroImage: NotificationImageModule?
    public var thumbnails: [NotificationImageModule]?
}
