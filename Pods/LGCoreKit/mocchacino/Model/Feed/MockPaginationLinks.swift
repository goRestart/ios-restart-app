public struct MockPaginationLinks: PaginationLinks {
    public var this: URL
    public var previous: URL?
    public var next: URL?
}

extension MockPaginationLinks: MockFactory {
    public static func makeMock() -> MockPaginationLinks {
        return MockPaginationLinks(this: URL.makeRandom(),
                                   previous: URL.makeRandom(),
                                   next: URL.makeRandom())
    }
}

