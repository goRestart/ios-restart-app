extension ProductCategory: MockFactory {
    public static func makeMock() -> ProductCategory {
        let allValues: [ProductCategory] = [.unassigned, .electronics, .carsAndMotors,
                                            .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                                            .fashionAndAccesories, .babyAndChild, .other]
        return allValues.random()!
    }
}
