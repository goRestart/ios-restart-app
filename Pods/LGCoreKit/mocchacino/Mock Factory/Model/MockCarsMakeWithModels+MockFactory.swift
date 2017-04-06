extension MockCarsMakeWithModels: MockFactory {
    public static func makeMock() -> MockCarsMakeWithModels {
        return MockCarsMakeWithModels(makeId: String.makeRandom(),
                             makeName: String.makeRandom(),
                             models: MockCarsModel.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
    }
}
