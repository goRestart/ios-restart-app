extension MockUserProductRelation: MockFactory {
    public static func makeMock() -> MockUserProductRelation {
        return MockUserProductRelation(isFavorited: Bool.makeRandom(),
                                       isReported: Bool.makeRandom())
    }
}
