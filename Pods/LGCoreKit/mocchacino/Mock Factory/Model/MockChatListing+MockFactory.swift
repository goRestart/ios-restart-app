extension MockChatListing: MockFactory {
    public static func makeMock() -> MockChatListing {
        return MockChatListing(objectId: String.makeRandom(),
                               name: String?.makeRandom(),
                               status: ListingStatus.makeMock(),
                               image: MockFile?.makeMock(),
                               price: ProductPrice.makeMock(),
                               currency: Currency.makeMock())
    }
}
