import Result

open class MockCategoryRepository: CategoryRepository {
    public var indexResult: CategoriesResult!


    // MARK: - Lifecycle

    required public init() {

    }

    
    // MARK: - CategoryRepository

    public func index(filterVisible filter: Bool, completion: CategoriesCompletion?) {
        delay(result: indexResult, completion: completion)
    }
}
