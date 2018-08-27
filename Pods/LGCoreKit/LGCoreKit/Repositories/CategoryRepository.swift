import Result

public typealias CategoriesResult = Result<[ListingCategory], RepositoryError>
public typealias CategoriesCompletion = (CategoriesResult) -> Void

public protocol CategoryRepository {
    func index(completion: CategoriesCompletion?)
}
