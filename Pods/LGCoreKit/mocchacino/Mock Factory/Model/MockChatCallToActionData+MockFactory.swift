extension MockChatCallToActionData: MockFactory {
    public static func makeMock() -> MockChatCallToActionData {
        return MockChatCallToActionData(key: String?.makeRandom(),
                                        title: String.makeRandom(),
                                        text: String.makeRandom(),
                                        image: MockChatCallToActionImage.makeMock())
    }
}
