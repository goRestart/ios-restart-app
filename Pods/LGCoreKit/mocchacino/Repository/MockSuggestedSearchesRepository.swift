import Result
import RxSwift

open class MockSearchRepository: SearchRepository {
    public var indexResult: TrendingSearchesResult!
    public var retrieveSuggestiveSearchResult: SuggestiveSearchesResult!

    
    // MARK: - Lifecycle

    required public init() {
        
    }


    // MARK: - SuggestedSearchesRepository {

    public func index(countryCode: String,
                      completion: TrendingSearchesCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    
    public func retrieveSuggestiveSearches(language: String,
                                           limit: Int,
                                           term: String,
                                           shouldIncludeCategories: Bool,
                                           completion: SuggestiveSearchesCompletion?) {
        delay(result: retrieveSuggestiveSearchResult, completion: completion)
    }
}
