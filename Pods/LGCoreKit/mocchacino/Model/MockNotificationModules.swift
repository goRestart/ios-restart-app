public struct MockNotificationTextModule: NotificationTextModule {
    public var title: String?
    public var body: String
    public var deeplink: String?
}

public struct MockNotificationImageModule: NotificationImageModule {
    public var shape: ImageShape?
    public var imageURL: String
    public var deeplink: String?
}

public struct MockNotificationCTAModule: NotificationCTAModule {
    public var title: String
    public var deeplink: String
}
