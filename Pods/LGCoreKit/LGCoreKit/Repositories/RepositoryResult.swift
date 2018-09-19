import Result

public typealias RepositoryResult<T> = Result<T, RepositoryError>
public typealias RepositoryCompletion<T> = (RepositoryResult<T>) -> Void
