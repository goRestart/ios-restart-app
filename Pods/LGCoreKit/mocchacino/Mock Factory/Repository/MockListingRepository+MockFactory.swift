
extension MockListingRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockListingRepository = self.init()

        mockListingRepository.indexResult = ListingsResult(value: Listing.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        mockListingRepository.listingResult = ListingResult(value: Listing.makeMock())
        mockListingRepository.listingVoidResult = ListingVoidResult(value: Void())
        mockListingRepository.carResult = CarResult(value: MockCar.makeMock())
        mockListingRepository.productResult = ProductResult(value: MockProduct.makeMock())
        mockListingRepository.deleteListingResult = ListingVoidResult(value: Void())
        mockListingRepository.markAsSoldResult = ListingResult(value: Listing.makeMock())
        mockListingRepository.markAsUnsoldResult = ListingResult(value: Listing.makeMock())
        mockListingRepository.userProductRelationResult = ListingUserRelationResult(value: MockUserListingRelation.makeMock())
        mockListingRepository.statsResult = ListingStatsResult(value: MockListingStats.makeMock())
        mockListingRepository.incrementViewsResult = ListingVoidResult(value: Void())
        mockListingRepository.listingBuyersResult = ListingBuyersResult(value: MockUserListing.makeMocks(count: Int.makeRandom(min: 0, max: 10)))

        return mockListingRepository
    }
}
