import Result

open class MockCategoryRepository: CategoryRepository {

    public var categoriesIndexResult: CategoriesResult!
    public var taxonomies: [Taxonomy]!

    // MARK: - Lifecycle

    required public init() {

    }

    
    // MARK: - CategoryRepository

    public func index(filterVisible filter: Bool, completion: CategoriesCompletion?) {
        delay(result: categoriesIndexResult, completion: completion)
    }

    public func indexTaxonomies() -> [Taxonomy] {
       return taxonomies
    }

    public func loadFirstRunCacheIfNeeded(jsonURL: URL) {

    }
    
    public func refreshTaxonomiesCache() {

    }
}
