extension MockChatCallToAction: MockFactory {
    public static func makeMock() -> MockChatCallToAction {
        return MockChatCallToAction(objectId: String?.makeRandom(),
                                        key: String.makeRandom(),
                                        content: MockChatCallToActionContent.makeMock())
    }
}
