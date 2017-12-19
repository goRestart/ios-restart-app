extension MockChatConversation: MockFactory {
    public static func makeMock() -> MockChatConversation {
        return MockChatConversation(objectId: String.makeRandom(),
                                    unreadMessageCount: Int.makeRandom(),
                                    lastMessageSentAt: Date.makeRandom(),
                                    amISelling: Bool.makeRandom(),
                                    listing: MockChatListing.makeMock(),
                                    interlocutor: MockChatInterlocutor.makeMock())
    }
}
