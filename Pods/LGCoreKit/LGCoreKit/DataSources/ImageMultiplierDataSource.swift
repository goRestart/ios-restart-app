import Result

typealias ImageMultiplierDataSourceResult = Result<[String], ApiError>
typealias ImageMultiplierDataSourceCompletion = (ImageMultiplierDataSourceResult) -> Void

protocol ImageMultiplierDataSource {
    func imageMultiplier(_ parameters: [String : Any], completion: ImageMultiplierDataSourceCompletion?)
}
