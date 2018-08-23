import Result
import RxSwift

open class MockFeedRepository: FeedRepository {
    
    public var indexParamsResult: FeedResult!
    public var indexUrlResult: FeedResult!
    
    required public init() {}
    
    public func index(parameters: FeedIndexParameters, completion: @escaping FeedCompletion) {
        delay(result: indexParamsResult, completion: completion)
    }
    
    public func index(page: URL, completion: @escaping FeedCompletion) {
        delay(result: indexUrlResult, completion: completion)
    }
}
