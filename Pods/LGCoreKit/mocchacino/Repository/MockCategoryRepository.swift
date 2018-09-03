import Result

open class MockCategoryRepository: CategoryRepository {
    public var categoriesIndexResult: CategoriesResult!
    required public init() { }
    
    // MARK: - CategoryRepository
    public func index(completion: CategoriesCompletion?)  {
        delay(result: categoriesIndexResult, completion: completion)
    }
}
