extension MockChat: MockFactory {
    public static func makeMock() -> MockChat {
        return MockChat(objectId: String.makeRandom(),
                        listing: Listing.product(MockProduct.makeMock()),
                        userFrom: MockUserListing.makeMock(),
                        userTo: MockUserListing.makeMock(),
                        msgUnreadCount: Int.makeRandom(),
                        messages: MockMessage.makeMocks(count: Int.makeRandom(min: 0, max: 10)),
                        updatedAt: Date?.makeRandom(),
                        forbidden: Bool.makeRandom(),
                        archivedStatus: ChatArchivedStatus.makeMock())
    }
}
