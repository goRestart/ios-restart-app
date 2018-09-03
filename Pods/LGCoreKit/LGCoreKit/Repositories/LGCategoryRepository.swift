final class LGCategoryRepository: CategoryRepository {
    init() {}

    func index(completion: CategoriesCompletion?) {
        completion?(CategoriesResult(value: ListingCategory.allValues))
    }
}
