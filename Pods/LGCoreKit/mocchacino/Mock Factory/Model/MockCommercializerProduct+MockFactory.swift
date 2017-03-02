extension MockCommercializerProduct: MockFactory {
    public static func makeMock() -> MockCommercializerProduct {
        return MockCommercializerProduct(objectId: String.makeRandom(),
                                         thumbnailURL: String.makeRandomURL(),
                                         countryCode: String?.makeRandom())
    }
}
