extension LGLocation: MockFactory {
    public static func makeMock() -> LGLocation {
        return LGLocation(latitude: Double.makeRandom(min: -90, max: 90),
                          longitude: Double.makeRandom(min: -180, max: 180),
                          type: LGLocationType.makeMock(),
                          postalAddress: PostalAddress?.makeMock())
    }
}
