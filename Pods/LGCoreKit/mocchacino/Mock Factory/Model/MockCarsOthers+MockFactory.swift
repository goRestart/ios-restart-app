extension MockCarsOthers: MockFactory {
    public static func makeMock() -> MockCarsOthers {
        return MockCarsOthers(makeId: String.makeRandom(),
                               modelId: String.makeRandom())
    }
}
