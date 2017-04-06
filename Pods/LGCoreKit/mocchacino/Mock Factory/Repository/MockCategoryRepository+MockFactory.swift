extension MockCategoryRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockCategoryRepository = self.init()
        mockCategoryRepository.indexResult = CategoriesResult(value: ListingCategory.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        return mockCategoryRepository
    }
}

