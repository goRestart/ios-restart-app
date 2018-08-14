final class LGCategoryRepository: CategoryRepository {
    init() {
    }

    func index(servicesIncluded: Bool,
               carsIncluded: Bool,
               realEstateIncluded: Bool,
               completion: CategoriesCompletion?) {
        completion?(CategoriesResult(value: ListingCategory.visibleValues(servicesIncluded: servicesIncluded,
                                                                          carsIncluded: carsIncluded,
                                                                          realEstateIncluded: realEstateIncluded)))
    }
}
