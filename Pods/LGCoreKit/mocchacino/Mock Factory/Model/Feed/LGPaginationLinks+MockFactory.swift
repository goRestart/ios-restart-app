extension LGPaginationLinks: MockFactory {
    
    public static func makeMock() -> LGPaginationLinks {
        return LGPaginationLinks(this: URL.makeRandom(), previous: URL.makeRandom(), next: URL.makeRandom())
    }
}
