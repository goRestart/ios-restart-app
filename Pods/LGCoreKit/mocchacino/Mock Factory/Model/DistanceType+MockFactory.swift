extension DistanceType: MockFactory {
    public static func makeMock() -> DistanceType {
        let allValues: [DistanceType] = [.mi, .km]
        return allValues.random()!
    }
}
