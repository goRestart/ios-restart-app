public struct MockChatConversation: ChatConversation {
    public var objectId: String?
    public var unreadMessageCount: Int
    public var lastMessageSentAt: Date?
    public var product: ChatProduct?
    public var interlocutor: ChatInterlocutor?
    public var amISelling: Bool
    
    func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result["conversation_id"] = objectId
        result["unread_messages_count"] = unreadMessageCount
        result["last_message_sent_at"] = Int64((lastMessageSentAt ?? Date()).timeIntervalSince1970 * 1000.0)
        result["am_i_selling"] = amISelling
        result["product"] = MockChatProduct.makeMock().makeDictionary()
        result["interlocutor"] = MockChatInterlocutor.makeMock().makeDictionary()
        return result
    }
}
