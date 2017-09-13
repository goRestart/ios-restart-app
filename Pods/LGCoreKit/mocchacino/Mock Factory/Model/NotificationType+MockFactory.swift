extension NotificationType: MockFactory {
    public static func makeMock() -> NotificationType {
        let modules = MockNotificationModular.makeMock()
        return .modular(modules: modules)
    }
}
