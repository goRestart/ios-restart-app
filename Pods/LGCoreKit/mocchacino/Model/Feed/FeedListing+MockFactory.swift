extension FeedListing: MockFactory {
    public static func makeMock() -> FeedListing {
        let mockListing = Listing.makeMock()
        return .product(mockListing)
    }
}
