public struct MockMessage: Message {
    public var objectId: String?
    public var text: String
    public var type: MessageType
    public var userId: String
    public var createdAt: Date?
    public var isRead: Bool
    public var warningStatus: MessageWarningStatus
}
