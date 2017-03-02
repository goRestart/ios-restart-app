import Result
import RxSwift

open class MockTrendingSearchesRepository: TrendingSearchesRepository {
    public var indexResult: TrendingSearchesResult


    // MARK: - Lifecycle

    public init() {
        self.indexResult = TrendingSearchesResult(value: [String].makeRandom())
    }


    // MARK: - TrendingSearchesRepository {

    public func index(_ countryCode: String, completion: TrendingSearchesCompletion?) {
        delay(result: indexResult, completion: completion)
    }
}
