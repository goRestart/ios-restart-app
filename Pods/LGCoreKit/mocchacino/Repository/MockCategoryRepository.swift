import Result

open class MockCategoryRepository: CategoryRepository {
    public var indexResult: CategoriesResult


    // MARK: - Lifecycle

    public init() {
        self.indexResult = CategoriesResult(value: ProductCategory.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
    }

    
    // MARK: - CategoryRepository

    public func index(filterVisible filter: Bool, completion: CategoriesCompletion?) {
        delay(result: indexResult, completion: completion)
    }
}
