import Result

public typealias ImageMultiplierResult = Result<[String], RepositoryError>
public typealias ImageMultiplierCompletion = (ImageMultiplierResult) -> Void

public protocol ImageMultiplierRepository {
    func imageMultiplier(_ parameters: ImageMultiplierParams,
                         completion: ImageMultiplierCompletion?)
}

