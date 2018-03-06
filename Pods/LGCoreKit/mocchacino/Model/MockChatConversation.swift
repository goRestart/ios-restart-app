import RxSwift
public struct MockChatConversation: ChatConversation {
    public var objectId: String?
    public var unreadMessageCount: Int
    public var lastMessageSentAt: Date?
    public var listing: ChatListing?
    public var interlocutor: ChatInterlocutor?
    public var amISelling: Bool
    public let interlocutorIsTyping = Variable<Bool>(false)
    
    public init(objectId: String?,
                unreadMessageCount: Int,
                lastMessageSentAt: Date?,
                amISelling: Bool,
                listing: ChatListing?,
                interlocutor: ChatInterlocutor?) {
        
        self.objectId = objectId
        self.unreadMessageCount = unreadMessageCount
        self.lastMessageSentAt = lastMessageSentAt
        self.listing = listing
        self.interlocutor = interlocutor
        self.amISelling = amISelling
    }
    
    func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result["conversation_id"] = objectId
        result["unread_messages_count"] = unreadMessageCount
        result["last_message_sent_at"] = Int64((lastMessageSentAt ?? Date()).timeIntervalSince1970 * 1000.0)
        result["am_i_selling"] = amISelling
        result["product"] = MockChatListing.makeMock().makeDictionary()
        result["interlocutor"] = MockChatInterlocutor.makeMock().makeDictionary()
        return result
    }
}
