extension MockUserListingRelation: MockFactory {
    public static func makeMock() -> MockUserListingRelation {
        return MockUserListingRelation(isFavorited: Bool.makeRandom(),
                                       isReported: Bool.makeRandom())
    }
}
