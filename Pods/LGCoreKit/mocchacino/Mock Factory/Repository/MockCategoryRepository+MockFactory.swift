extension MockCategoryRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockCategoryRepository = self.init()
        mockCategoryRepository.categoriesIndexResult = CategoriesResult(value: ListingCategory.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        mockCategoryRepository.taxonomiesIndexResult = TaxonomiesResult(value: MockTaxonomy.makeMocks(count: Int.makeRandom(min: 0, max: 10)))

        return mockCategoryRepository
    }
}

