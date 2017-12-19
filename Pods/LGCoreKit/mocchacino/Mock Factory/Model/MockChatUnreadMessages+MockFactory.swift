extension MockChatUnreadMessages: MockFactory {
    public static func makeMock() -> MockChatUnreadMessages {
        return MockChatUnreadMessages(totalUnreadMessages: Int.makeRandom())
    }
}
