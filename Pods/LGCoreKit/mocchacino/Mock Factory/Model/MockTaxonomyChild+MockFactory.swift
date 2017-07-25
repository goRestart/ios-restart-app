extension MockTaxonomyChild: MockFactory {
    public static func makeMock() -> MockTaxonomyChild {
        let randomType = Bool.makeRandom()
        let isHighlighted = Bool.makeRandom()
        return MockTaxonomyChild(id: Int.makeRandom(),
                                 type: randomType ? .superKeyword : .category,
                                 name: String.makeRandom(),
                                 highlightOrder: isHighlighted ? Int.makeRandom() : nil,
                                 highlightIcon: isHighlighted ? URL.makeRandom() : nil,
                                 image: URL?.makeRandom())
    }
}
