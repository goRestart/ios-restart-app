import Result
        
extension MockOldChatRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockOldChatRepository = self.init()
        mockOldChatRepository.indexResult = ChatsResult(value: MockChat.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        mockOldChatRepository.retrieveResult = ChatResult(value: MockChat.makeMock())
        mockOldChatRepository.unreadMsgCountResult = Result<Int, RepositoryError>(value: Int.makeRandom())
        mockOldChatRepository.sendMsgResult = MessageResult(value: MockMessage.makeMock())
        mockOldChatRepository.archiveResult = Result<Void, RepositoryError>(value: Void())
        return mockOldChatRepository
    }
}
