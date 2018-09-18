import Result

public typealias DataSourceResult<T> = Result<T, ApiError>
public typealias DataSourceCompletion<T> = (DataSourceResult<T>) -> Void
