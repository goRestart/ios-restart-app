extension MockChatRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockChatRepository = self.init()
        mockChatRepository.indexMessagesResult = ChatMessagesResult(value: MockChatMessage.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        mockChatRepository.indexConversationsResult = ChatConversationsResult(value: MockChatConversation.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        mockChatRepository.showConversationResult = ChatConversationResult(value: MockChatConversation.makeMock())
        mockChatRepository.commandResult = ChatCommandResult(value: Void())
        mockChatRepository.unreadMessagesResult = ChatUnreadMessagesResult(value: MockChatUnreadMessages.makeMock())
        return mockChatRepository
    }
}
