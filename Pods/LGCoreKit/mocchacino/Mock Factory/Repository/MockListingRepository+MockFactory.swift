
extension MockListingRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockProductRepository = self.init()

        mockProductRepository.indexResult = ListingsResult(value: Listing.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        mockProductRepository.listingResult = ListingResult(value: Listing.makeMock())
        mockProductRepository.listingVoidResult = ListingVoidResult(value: Void())
        mockProductRepository.carResult = CarResult(value: MockCar.makeMock())
        mockProductRepository.productResult = ProductResult(value: MockProduct.makeMock())
        mockProductRepository.deleteProductResult = ListingVoidResult(value: Void())
        mockProductRepository.markAsSoldResult = ListingResult(value: Listing.makeMock())
        mockProductRepository.markAsUnsoldResult = ListingResult(value: Listing.makeMock())
        mockProductRepository.userProductRelationResult = ListingUserRelationResult(value: MockUserListingRelation.makeMock())
        mockProductRepository.statsResult = ListingStatsResult(value: MockListingStats.makeMock())
        mockProductRepository.incrementViewsResult = ListingVoidResult(value: Void())
        mockProductRepository.listingBuyersResult = ListingBuyersResult(value: MockUserListing.makeMocks(count: Int.makeRandom(min: 0, max: 10)))

        return mockProductRepository
    }
}
