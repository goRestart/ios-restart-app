extension MockSuggestiveSearch: MockFactory {
    public static func makeMock() -> MockSuggestiveSearch {
        return MockSuggestiveSearch(name: String.makeRandom(),
                                    category: Optional<ListingCategory>.makeMock())
    }
}
