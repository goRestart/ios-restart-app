extension MockListingFavourite: MockFactory {
    public static func makeMock() -> MockListingFavourite {
        return MockListingFavourite(objectId: String.makeRandom(),
                                    product: MockProduct.makeMock(),
                                    user: MockUserListing.makeMock())
    }
}
