extension MockCarsInfo: MockFactory {
    public static func makeMock() -> MockCarsInfo {
        return MockCarsInfo(makesList: MockCarsMake.makeMocks(count: Int.makeRandom(min: 0, max: 10)),
                            others: MockCarsOthers.makeMock())
    }
}
