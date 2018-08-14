import Result

typealias FeedDataSourceResult = Result<Feed, ApiError>
typealias FeedDataSourceCompletion = (FeedDataSourceResult) -> Void

protocol FeedDataSource {
    func index(parameters: FeedIndexParameters, completion: FeedDataSourceCompletion?)
    
    func index(page: URL, completion: FeedDataSourceCompletion?)
}
