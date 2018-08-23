import Result

public typealias CategoriesResult = Result<[ListingCategory], RepositoryError>
public typealias CategoriesCompletion = (CategoriesResult) -> Void

public protocol CategoryRepository {
    func index(servicesIncluded: Bool,
               carsIncluded: Bool,
               realEstateIncluded: Bool,
               completion: CategoriesCompletion?)
}
