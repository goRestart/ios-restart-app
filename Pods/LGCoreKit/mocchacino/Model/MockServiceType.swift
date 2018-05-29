public struct MockServiceType: ServiceType {
    public let id: String
    public let name: String
    public let subTypes: [ServiceSubtype]
}

extension MockServiceType: MockFactory {
    public static func makeMock() -> MockServiceType {
        return MockServiceType(id: String.makeRandom(),
                               name: String.makeRandom(),
                               subTypes: MockServiceSubtype.makeMocks(count: Int.makeRandom(min: 0, max: 20)))
    }
}

public struct MockServiceSubtype: ServiceSubtype {
    public let id: String
    public let name: String
    public let isHighlighted: Bool
}

extension MockServiceSubtype: MockFactory {
    public static func makeMock() -> MockServiceSubtype {
        return MockServiceSubtype(id: String.makeRandom(),
                                  name: String.makeRandom(),
                                  isHighlighted: Bool.makeRandom())
    }
}
