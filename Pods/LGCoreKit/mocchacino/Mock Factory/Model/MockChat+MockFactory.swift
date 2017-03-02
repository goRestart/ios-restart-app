extension MockChat: MockFactory {
    public static func makeMock() -> MockChat {
        return MockChat(objectId: String.makeRandom(),
                        product: MockProduct.makeMock(),
                        userFrom: MockUserProduct.makeMock(),
                        userTo: MockUserProduct.makeMock(),
                        msgUnreadCount: Int.makeRandom(),
                        messages: MockMessage.makeMocks(count: Int.makeRandom(min: 0, max: 10)),
                        updatedAt: Date?.makeRandom(),
                        forbidden: Bool.makeRandom(),
                        archivedStatus: ChatArchivedStatus.makeMock())
    }
}
