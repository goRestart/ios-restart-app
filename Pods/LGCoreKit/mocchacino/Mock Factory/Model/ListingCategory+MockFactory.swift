extension ListingCategory: MockFactory {
    public static func makeMock() -> ListingCategory {
        let allValues: [ListingCategory] = [.unassigned, .electronics, .motorsAndAccessories,
                                            .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                                            .fashionAndAccesories, .babyAndChild, .other]
        return allValues.random()!
    }
}