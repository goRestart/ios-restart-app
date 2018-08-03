extension MockChatCallToActionContent: MockFactory {
    public static func makeMock() -> MockChatCallToActionContent {
        return MockChatCallToActionContent(text: String.makeRandom(),
                                           deeplinkURL: URL?.makeRandom())
    }
}
