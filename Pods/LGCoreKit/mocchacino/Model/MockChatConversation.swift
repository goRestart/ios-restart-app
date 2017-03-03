public struct MockChatConversation: ChatConversation {
    public var objectId: String?
    public var unreadMessageCount: Int
    public var lastMessageSentAt: Date?
    public var product: ChatProduct?
    public var interlocutor: ChatInterlocutor?
    public var amISelling: Bool
}
