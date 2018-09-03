import LGCoreKit

final class FeedRequester {
    
    private let initialIndexParams: FeedIndexParameters
    private let feedRepository: FeedRepository
    
    init(withRepository repository: FeedRepository,
         params: FeedIndexParameters) {
        feedRepository = repository
        initialIndexParams = params
    }

}

extension FeedRequester: RequesterURLPaginable {
    
    func retrieve(_ completion: @escaping FeedCompletion) {
        feedRepository.index(parameters: initialIndexParams, completion: completion)
    }
    
    func retrieve(nextURL url: URL, _ completion: @escaping FeedCompletion) {
        feedRepository.index(page: url, completion: completion)
    }
    
}

