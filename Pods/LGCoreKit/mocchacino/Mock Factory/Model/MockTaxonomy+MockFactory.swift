extension MockTaxonomy: MockFactory {
    public static func makeMock() -> MockTaxonomy {
        let hasIcon = Bool.makeRandom()
        return MockTaxonomy(name: String.makeRandom(),
                            icon: hasIcon ? URL.makeRandom() : nil,
                            children: MockTaxonomyChild.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
    }
}
