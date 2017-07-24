import Result
import RxSwift

open class MockSearchRepository: SearchRepository {
    public var indexResult: TrendingSearchesResult!
    public var retrieveSuggestiveSearchResult: SuggestiveSearchesResult!

    
    // MARK: - Lifecycle

    required public init() {
        
    }


    // MARK: - SuggestedSearchesRepository {

    public func index(_ countryCode: String, completion: TrendingSearchesCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    
    public func retrieveSuggestiveSearches(_ countryCode: String, limit: Int, term: String, completion: SuggestiveSearchesCompletion?) {
        delay(result: retrieveSuggestiveSearchResult, completion: completion)
    }
}
