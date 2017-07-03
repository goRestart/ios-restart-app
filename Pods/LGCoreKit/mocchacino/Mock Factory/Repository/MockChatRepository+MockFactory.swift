extension MockChatRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockChatRepository = self.init()
        mockChatRepository.indexMessagesResult = ChatMessagesResult(value: MockChatMessage.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        mockChatRepository.indexConversationsResult = ChatConversationsResult(value: MockChatConversation.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        mockChatRepository.showConversationResult = ChatConversationResult(value: MockChatConversation.makeMock())
        mockChatRepository.confirmReadCommandResult = ChatCommandResult(value: Void())
        mockChatRepository.confirmReceptionCommandResult = ChatCommandResult(value: Void())
        mockChatRepository.archiveCommandResult = ChatCommandResult(value: Void())
        mockChatRepository.unarchiveCommandResult = ChatCommandResult(value: Void())
        mockChatRepository.sendMessageCommandResult = ChatCommandResult(value: Void())
        mockChatRepository.unreadMessagesResult = ChatUnreadMessagesResult(value: MockChatUnreadMessages.makeMock())
        return mockChatRepository
    }
}
