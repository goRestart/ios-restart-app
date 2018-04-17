extension MockSuggestedLocation: MockFactory {
    public static func makeMock() -> MockSuggestedLocation {
        return MockSuggestedLocation(locationId: String.makeRandom(),
                                     locationName: String.makeRandom(),
                                     locationAddress: String?.makeRandom(),
                                     locationCoords: LGLocationCoordinates2D.makeMock())
    }
}
