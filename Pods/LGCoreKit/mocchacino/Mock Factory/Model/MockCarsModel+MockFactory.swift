extension MockCarsModel: MockFactory {
    public static func makeMock() -> MockCarsModel {
        return MockCarsModel(modelId: String.makeRandom(),
                              modelName: String.makeRandom())
    }
}
