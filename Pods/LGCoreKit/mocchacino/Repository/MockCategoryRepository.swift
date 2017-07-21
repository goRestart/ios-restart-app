import Result

open class MockCategoryRepository: CategoryRepository {

    public var categoriesIndexResult: CategoriesResult!
    public var taxonomiesIndexResult: TaxonomiesResult!

    // MARK: - Lifecycle

    required public init() {

    }

    
    // MARK: - CategoryRepository

    public func index(filterVisible filter: Bool, completion: CategoriesCompletion?) {
        delay(result: categoriesIndexResult, completion: completion)
    }

    public func indexTaxonomies(withCompletion completion: TaxonomiesCompletion?) {
        delay(result: taxonomiesIndexResult, completion: completion)
    }

    public func loadFirstRunCacheIfNeeded(jsonURL: URL) {

    }
    
    public func refreshTaxonomiesCache() {

    }
}
