extension MockCarsMake: MockFactory {
    public static func makeMock() -> MockCarsMake {
        return MockCarsMake(makeId: String.makeRandom(),
                             makeName: String.makeRandom(),
                             models: MockCarsModel.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
    }
}
