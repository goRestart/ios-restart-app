public protocol MockFactory {
    static func makeMock() -> Self
}

public extension MockFactory {
    public static func makeMocks(count: Int = Int.makeRandom()) -> [Self] {
        return (0..<count).map { _ in Self.makeMock() }
    }
}
