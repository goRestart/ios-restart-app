extension MockMessage: MockFactory {
    public static func makeMock() -> MockMessage {
        return MockMessage(objectId: String.makeRandom(),
                           text: String.makeRandom(),
                           type: MessageType.makeMock(),
                           userId: String.makeRandom(),
                           createdAt: Date?.makeRandom(),
                           isRead: Bool.makeRandom(),
                           warningStatus: MessageWarningStatus.makeMock())
    }
}
