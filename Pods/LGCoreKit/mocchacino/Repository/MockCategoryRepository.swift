import Result

open class MockCategoryRepository: CategoryRepository {

    public var categoriesIndexResult: CategoriesResult!


    // MARK: - Lifecycle

    required public init() {

    }

    
    // MARK: - CategoryRepository

    public func index(servicesIncluded: Bool,
                      carsIncluded: Bool,
                      realEstateIncluded: Bool,
                      completion: CategoriesCompletion?)  {
        delay(result: categoriesIndexResult, completion: completion)
    }
}
