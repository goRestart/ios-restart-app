import Result
import RxSwift

open class MockSuggestedSearchesRepository: SuggestedSearchesRepository {
    public var indexResult: SuggestedSearchesResult!
    public var retrieveSuggestiveSearchesResult: SuggestiveSearchesResult!

    
    // MARK: - Lifecycle

    required public init() {
        
    }


    // MARK: - SuggestedSearchesRepository {

    public func index(_ countryCode: String, completion: SuggestedSearchesCompletion?) {
        delay(result: indexResult, completion: completion)
    }
    
    public func retrieveSuggestiveSearches(_ countryCode: String, limit: Int, term: String, completion: SuggestiveSearchesCompletion?) {
        delay(result: retrieveSuggestiveSearchesResult, completion: completion)
    }
}
