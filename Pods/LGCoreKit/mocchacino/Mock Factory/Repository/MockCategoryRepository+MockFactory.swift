extension MockCategoryRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockCategoryRepository = self.init()
        let categoriesIndexResult = CategoriesResult(value: ListingCategory.makeMocks(count: Int.makeRandom(min: 0,
                                                                                                            max: 11)))
        mockCategoryRepository.categoriesIndexResult = categoriesIndexResult
        return mockCategoryRepository
    }
}

