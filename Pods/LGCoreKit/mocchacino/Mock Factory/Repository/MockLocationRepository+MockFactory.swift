extension MockLocationRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockLocationRepository = self.init()
        mockLocationRepository.suggestionsResult = SuggestionsLocationRepositoryResult(value: [Place].makeMocks())
        mockLocationRepository.postalAddressResult = PostalAddressLocationRepositoryResult(value: Place.makeMock())
        mockLocationRepository.ipLookupLocationResult = IPLookupLocationRepositoryResult(value: LGLocationCoordinates2D.makeMock())
        return mockLocationRepository
    }
}
