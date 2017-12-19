extension LGLocationType: MockFactory {
    public static func makeMock() -> LGLocationType {
        let allValues: [LGLocationType] = [.manual, .sensor, .ipLookup, regional]
        return allValues.random()!
    }
}
