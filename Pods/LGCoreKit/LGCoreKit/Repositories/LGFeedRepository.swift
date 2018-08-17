import Foundation

final class LGFeedRepository: FeedRepository {
    
    private let datasource: FeedDataSource
    
    init(datasource: FeedDataSource) {
        self.datasource = datasource
    }
    
    func index(parameters: FeedIndexParameters, completion: @escaping FeedCompletion) {
        datasource.index(parameters: parameters) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    func index(page: URL, completion: @escaping FeedCompletion) {
        datasource.index(page: page) { result in
            handleApiResult(result, completion: completion)
        }
    }
}
