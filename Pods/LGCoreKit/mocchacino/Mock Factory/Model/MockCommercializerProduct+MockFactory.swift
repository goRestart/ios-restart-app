extension MockCommercializerListing: MockFactory {
    public static func makeMock() -> MockCommercializerListing {
        return MockCommercializerListing(objectId: String.makeRandom(),
                                         thumbnailURL: String.makeRandomURL(),
                                         countryCode: String?.makeRandom())
    }
}
