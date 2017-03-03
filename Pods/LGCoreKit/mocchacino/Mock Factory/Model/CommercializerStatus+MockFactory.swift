extension CommercializerStatus: MockFactory {
    public static func makeMock() -> CommercializerStatus {
        let allValues: [CommercializerStatus] = [.unavailable, .processing, .ready]
        return allValues.random()!
    }
}
