extension LGLocationCoordinates2D: MockFactory {
    public static func makeMock() -> LGLocationCoordinates2D {
        return LGLocationCoordinates2D(latitude: Double.makeRandom(min: -90, max: 90),
                                       longitude: Double.makeRandom(min: -180, max: 180))
    }
}
