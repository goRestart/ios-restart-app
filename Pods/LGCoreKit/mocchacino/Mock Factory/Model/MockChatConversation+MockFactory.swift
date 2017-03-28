extension MockChatConversation: MockFactory {
    public static func makeMock() -> MockChatConversation {
        return MockChatConversation(objectId: String.makeRandom(),
                                    unreadMessageCount: Int.makeRandom(),
                                    lastMessageSentAt: Date?.makeRandom(),
                                    product: MockChatListing.makeMock(),
                                    interlocutor: MockChatInterlocutor.makeMock(),
                                    amISelling: Bool.makeRandom())
    }
}
