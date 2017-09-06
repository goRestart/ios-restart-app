extension MockLocationRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockLocationRepository = self.init()
        mockLocationRepository.suggestionsResult = LocationSuggestionsRepositoryResult(value: [Place].makeMocks())
        mockLocationRepository.suggestionDetailsResult = LocationSuggestionDetailsRepositoryResult(value: Place.makeMock())
        mockLocationRepository.postalAddressResult = PostalAddressLocationRepositoryResult(value: Place.makeMock())
        mockLocationRepository.ipLookupLocationResult = IPLookupLocationRepositoryResult(value: LGLocationCoordinates2D.makeMock())
        return mockLocationRepository
    }
}
