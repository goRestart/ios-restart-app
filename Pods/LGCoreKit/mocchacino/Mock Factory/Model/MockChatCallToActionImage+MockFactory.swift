extension MockChatCallToActionImage: MockFactory {
    public static func makeMock() -> MockChatCallToActionImage {
        return MockChatCallToActionImage(url: String.makeRandom(),
                                         position: Bool.makeRandom() ? .up : .down )
    }
}
