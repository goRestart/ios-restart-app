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
        result[LGChatConversation.CodingKeys.objectId.rawValue] = objectId
        result[LGChatConversation.CodingKeys.unreadMessageCount.rawValue] = unreadMessageCount
        result[LGChatConversation.CodingKeys.lastMessageSentAt.rawValue] = Int64((lastMessageSentAt ?? Date()).timeIntervalSince1970 * 1000.0)
        result[LGChatConversation.CodingKeys.amISelling.rawValue] = amISelling
        result[LGChatConversation.CodingKeys.listing.rawValue] = MockChatListing.makeMock().makeDictionary()
        result[LGChatConversation.CodingKeys.interlocutor.rawValue] = MockChatInterlocutor.makeMock().makeDictionary()
        return result
    }
}
