extension LGFeedItemGeoData: MockFactory {
    public static func makeMock() -> LGFeedItemGeoData {
        return LGFeedItemGeoData(
            location: LGLocationCoordinates2D.makeMock(),
            countryCode: String.makeRandom(),
            city: String.makeRandom(),
            zipCode: String.makeRandom())
    }
}
