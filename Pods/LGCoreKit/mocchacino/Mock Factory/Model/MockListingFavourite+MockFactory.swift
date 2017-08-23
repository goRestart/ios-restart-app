extension MockListingFavourite: MockFactory {
    public static func makeMock() -> MockListingFavourite {
        return MockListingFavourite(objectId: String.makeRandom(),
                                    listing: Listing.makeMock(),
                                    user: MockUserListing.makeMock())
    }
}
