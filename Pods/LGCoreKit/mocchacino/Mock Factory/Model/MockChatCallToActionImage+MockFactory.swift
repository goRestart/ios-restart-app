extension MockChatCallToActionImage: MockFactory {
    public static func makeMock() -> MockChatCallToActionImage {
        return MockChatCallToActionImage(imageURL: URL(string: "http://" + String.makeRandom()),
                                         position: Bool.makeRandom() ? .up : .down )
    }
}
