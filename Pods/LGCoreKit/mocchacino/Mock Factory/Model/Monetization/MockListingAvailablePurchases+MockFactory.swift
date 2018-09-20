extension MockListingAvailablePurchases: MockFactory {
    public static func makeMock() -> MockListingAvailablePurchases {
        return MockListingAvailablePurchases(listingId: String.makeRandom(),
                                             purchases: MockAvailableFeaturePurchases.makeMock())
    }
}
